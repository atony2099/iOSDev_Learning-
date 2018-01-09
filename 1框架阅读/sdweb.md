---
title: SDWeb源码简析
date: 2016-08-11 23:38:06
tags:
---





![](http://w5.sanwen8.cn/mmbiz/UYtP5BLQsBdY7k8zbzYM9icvSM09RQre1U4YibzrQIXdGzEMicHGlwgd41rkncnYLkOciaiclOyxEWR9qVKAAMeuNibA/0?wx_fmt=jpeg)



#### 主方法

```objective-c

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock {
    
    // cancel operationDictionary operation
    [self sd_cancelCurrentImageLoad];    // 取消正在下载操作
    
    // sd_imageURL赋值
    objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    if (!(options & SDWebImageDelayPlaceholder)) {
        // 主线程更新ui
        dispatch_main_async_safe(^{
            self.image = placeholder;  // 设置占位图
        });
    }
  
    if (url) {
        // check if activityView is enabled or not
        if ([self showActivityIndicatorView]) {
            [self addActivityIndicator]; // 添加加载view
        }

        __weak __typeof(self)wself = self;
        id <SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadImageWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            [wself removeActivityIndicator];
            if (!wself) return;
            dispatch_main_sync_safe(^{
                if (!wself) return;
                if (image && (options & SDWebImageAvoidAutoSetImage) && completedBlock) // 不直接赋值给imageView
                {
                    completedBlock(image, error, cacheType, url);
                    return;
                }
                else if (image) {
                    wself.image = image;
                    [wself setNeedsLayout];
                } else {
                    if ((options & SDWebImageDelayPlaceholder)) {
                        wself.image = placeholder;
                        [wself setNeedsLayout];
                    }
                }
                if (completedBlock && finished) {
                    completedBlock(image, error, cacheType, url);
                }
            });
        }];
      // 为imageView绑定新的操作
        [self sd_setImageLoadOperation:operation forKey:@"UIImageViewImageLoad"];
    } else {
        dispatch_main_async_safe(^{
            [self removeActivityIndicator];
            if (completedBlock) {
                NSError *error = [NSError errorWithDomain:SDWebImageErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
                completedBlock(nil, error, SDImageCacheTypeNone, url);
            }
        });
    }
}
```



```objective-c
- (id <SDWebImageOperation>)downloadImageWithURL:(NSURL *)url
                                         options:(SDWebImageOptions)options
                                        progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                       completed:(SDWebImageCompletionWithFinishedBlock)completedBlock {
      
    __block SDWebImageCombinedOperation *operation = [SDWebImageCombinedOperation new];
                       
                                         
      // 缓存查找                                   
     operation.cacheOperation = [self.imageCache queryDiskCacheForKey:key done:^(UIImage *image, SDImageCacheType cacheType) {
        if (operation.isCancelled) {
            @synchronized (self.runningOperations) {
                [self.runningOperations removeObject:operation];
            }
            return;
        }
				//条件1:在缓存中没有找到图片或者options选项里面包含了SDWebImageRefreshCached(这两项都需要进行请求网络图片的)
//条件2:代理允许下载,SDWebImageManagerDelegate的delegate不能响应imageManager:shouldDownloadImageForURL:方法或者能响应方法且方法返回值为YES.也就是没有实现这个方法就是允许的,如果实现了的话,返回YES才是允许

               if ((!image || options & SDWebImageRefreshCached) && (![self.delegate respondsToSelector:@selector(imageManager:shouldDownloadImageForURL:)] || [self.delegate imageManager:self shouldDownloadImageForURL:url])) {
      // 下载操作           
    id <SDWebImageOperation> subOperation = [self.imageDownloader downloadImageWithURL:url options:downloaderOptions progress:progressBlock completed:^(UIImage *downloadedImage, NSData *data, NSError *error, BOOL finished) { 
            }];
                 
        }      
       //处理其他情况
//case1.在缓存中找到图片(代理不允许下载 或者没有设置SDWebImageRefreshCached选项  满足至少一项)
       else if (image) {
            dispatch_main_sync_safe(^{
                __strong __typeof(weakOperation) strongOperation = weakOperation;
                if (strongOperation && !strongOperation.isCancelled) {
                    completedBlock(image, nil, cacheType, YES, url);
                }
            });
            @synchronized (self.runningOperations) {
                [self.runningOperations removeObject:operation];
            }
        }
       
  //case2:缓存中没有扎到图片且代理不允许下载
        else {
        //主线程执行完成回调
            dispatch_main_sync_safe(^{
                __strong __typeof(weakOperation) strongOperation = weakOperation;
                if (strongOperation && !weakOperation.isCancelled) {
                    completedBlock(nil, nil, SDImageCacheTypeNone, YES, url);
                }
            });
          //从正在执行的操作列表中移除组合操作
            @synchronized (self.runningOperations) {
                [self.runningOperations removeObject:operation];
            }
        }

              
              
    }];

    return operation;                    
  }
                                 
                        
```



#### 下载

关键点

- 回调放在barrierQueue，并行队列，在这个队列上统一处理中的数据回调，为了保证线程安全，一致使用dispatch_barrier_sync，保证同一个url 不会被重复下载
- 下载operation 放在downloadQueue中





```objective-c
- (id <SDWebImageOperation>)downloadImageWithURL:(NSURL *)url 
                                         options:(SDWebImageDownloaderOptions)options 
                                        progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                       completed:(SDWebImageDownloaderCompletedBlock)completedBlock {

            __block SDWebImageDownloaderOperation *operation;b
            [self addProgressCallback:progressBlock 
                       completedBlock:completedBlock 
                               forURL:url 
                        createCallback:^{
      //创建下载的回调,我们开始来看看创建完下载的回调之后里面都写了什么事情

      //配置下载超时的时间
         NSTimeInterval timeoutInterval = wself.downloadTimeout;
       if (timeoutInterval == 0.0) {
         timeoutInterval = 15.0;
       }

   /**
         创建请求对象,并根据options参数设置其属性 
         为了避免潜在的重复缓存(NSURLCache + SDImageCache)，
        如果没有明确告知需要缓存，
        则禁用图片请求的缓存操作, 这样就只有SDImageCache进行了缓存
这里的options 是SDWebImageDownloaderOptions
      */
  NSMutableURLRequest *request = 
[[NSMutableURLRequest alloc] initWithURL:url 
cachePolicy:(options & SDWebImageDownloaderUseNSURLCache ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData) 
timeoutInterval:timeoutInterval];

// 通过设置 NSMutableURLRequest.HTTPShouldHandleCookies = YES
//的方式来处理存储在NSHTTPCookieStore的cookies
        request.HTTPShouldHandleCookies = (options & SDWebImageDownloaderHandleCookies);
//返回在接到上一个请求得得响应之前,饰扣需要传输数据,YES传输,NO不传输
        request.HTTPShouldUsePipelining = YES;
  }];
};

/**
如果你自定义了wself.headersFilter,那就用你自己设置的
wself.headersFilter来设置HTTP的header field
它的定义是
typedef NSDictionary *(^SDWebImageDownloaderHeadersFilterBlock)(NSURL *url, NSDictionary *headers);
一个返回结果为NSDictionary类型的block

如果你没有自己设置wself.headersFilter那么就用SDWebImage提供的HTTPHeaders
HTTPHeaders在#import "SDWebImageDownloader.h",init方法里面初始化,下载webp图片需要的header不一样
(WebP格式，[谷歌]开发的一种旨在加快图片加载速度的图片格式。图片压缩体积大约只有JPEG的2/3，并能节省大量的服务器带宽资源和数据空间)
#ifdef SD_WEBP
        _HTTPHeaders = [@{@"Accept": @"image/webp,image/*;q=0.8"} mutableCopy];
#else
        _HTTPHeaders = [@{@"Accept": @"image/*;q=0.8"} mutableCopy];
#endif
*/
  if (wself.headersFilter) {
            request.allHTTPHeaderFields = wself.headersFilter(url, [wself.HTTPHeaders copy]);
        }
        else {
            request.allHTTPHeaderFields = wself.HTTPHeaders;
        }

/**
创建SDWebImageDownLoaderOperation操作对象(下载的操作就是在SDWebImageDownLoaderOperation类里面进行的)
传入了进度回调,完成回调,取消回调

@property (assign, nonatomic) Class operationClass;
将Class作为属性存储,初始化具体Class,使用的时候调用具体class的方法
*/

    operation = [[wself.operationClass alloc] initWithRequest:request
                                                          options:options
                                                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
 	//progress block回调的操作                                                            			SDWebImageDownloader *sself = wself;
                                                             if (!sself) return;
                                                             __block NSArray *callbacksForURL;
  /**
URLCallbacks是一个字典,key是url,value是一个数组,
数组里面装的是字典,key是NSString代表着回调类型,value为block是对应的回调                                                        
确保提交的block是指定队列中特定时段唯一在执行的一个.
*/
dispatch_sync(sself.barrierQueue, ^{
            //根据key取出装了字典的数组
                callbacksForURL = [sself.URLCallbacks[url] copy];
        });
  for (NSDictionary *callbacks in callbacksForURL) {
       dispatch_async(dispatch_get_main_queue(), ^{
  //根据kProgressCallbackKey这个key取出进度的操作
      SDWebImageDownloaderProgressBlock callback = callbacks[kProgressCallbackKey];
      //返回已经接收的数据字节,以及未接收的数据(预计字节)
     if (callback) callback(receivedSize, expectedSize);
          });
         }
      }
    completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            //completed block 回调的操作
                     SDWebImageDownloader *sself = wself;
                     if (!sself) return;
            //依旧是根据url这个key取出一个里面装了字典的数组
                     __block NSArray *callbacksForURL;
                     dispatch_barrier_sync(sself.barrierQueue, ^{
                         callbacksForURL = [sself.URLCallbacks[url] copy];
                       if (finished) {
        //如果这个任务已经完成,就根据url这个key从URLCallbacks字典里面删除
                                     [sself.URLCallbacks removeObjectForKey:url];
                                        }
                                         });
         for (NSDictionary *callbacks in callbacksForURL) {
  //根据kCompletedCallbackKey这个key取出SDWebImageDownloaderCompletedBlock(完成的block)
                SDWebImageDownloaderCompletedBlock callback = callbacks[kCompletedCallbackKey];
            //回调 图片 data error 是否完成的
             if (callback) callback(image, data, error, finished);
                                                            }
                                                        }
                                                        cancelled:^{
            //将url对应的所有回调移除                                                SDWebImageDownloader *sself = wself;
                                                            if (!sself) return;
                                                            dispatch_barrier_async(sself.barrierQueue, ^{
                                                                [sself.URLCallbacks removeObjectForKey:url];
                                                            });
                                                        }];

//上面 是SDWebImageDownloaderOperation *operation的创建,从这里开始就都是对operation的配置

 // 设置是否需要解压
 operation.shouldDecompressImages = wself.shouldDecompressImages;

/**
用户认证 NSURLCredential
当连接客户端与服务端进行数据传输的时候,web服务器
收到客户端请求时可能需要先验证客户端是否是正常用户,再决定是否返回该接口的真实数据

iOS7.0之前使用的网络框架是NSURLConnection,在 2013 的 WWDC 上，
苹果推出了 NSURLConnection 的继任者：NSURLSession

SDWebImage使用的是NSURLConnection,这两种网络框架的认证调用的方法也是不一样的,有兴趣的可以去google一下这里只看下NSURLConnection的认证(在这里写看着有些吃力,移步到这个代码框外面阅读)

*/ 
        if (wself.urlCredential) {
            operation.credential = wself.urlCredential;
        } else if (wself.username && wself.password) {
            operation.credential = [NSURLCredential credentialWithUser:wself.username password:wself.password persistence:NSURLCredentialPersistenceForSession];
        }

//根据下载选项SDWebImageDownloaderHighPriority设置优先级
        if (options & SDWebImageDownloaderHighPriority) {
            operation.queuePriority = NSOperationQueuePriorityHigh;
        } else if (options & SDWebImageDownloaderLowPriority) {
            operation.queuePriority = NSOperationQueuePriorityLow;
        }
  //将下载操作加到下载队列中
        [wself.downloadQueue addOperation:operation];
        if (wself.executionOrder == SDWebImageDownloaderLIFOExecutionOrder) {
   /**
 根据executionOrder设置操作的依赖关系
  executionOrder代表着下载操作执行的顺序,它是一个枚举
SD添加下载任务是同步的，而且都是在self.barrierQueue这个并行队列中，
同步添加任务。这样也保证了根据executionOrder设置依赖关是正确的。
换句话说如果创建下载任务不是使用dispatch_barrier_sync完成的，而是使用异步方法 ，虽然依次添加创建下载操作A、B、C的任务，但实际创建顺序可能为A、C、B，这样当executionOrder的值是SDWebImageDownloaderLIFOExecutionOrder，设置的操作依赖关系就变成了A依赖C，C依赖B

typedef NS_ENUM(NSInteger, SDWebImageDownloaderExecutionOrder) { 
// 默认值，所有的下载操作以队列类型执行,先被加入下载队列的操作先执行
SDWebImageDownloaderFIFOExecutionOrder,
// 所有的下载操作以栈类型执行,后进先出,后被加入下载队列的操作先执行
SDWebImageDownloaderLIFOExecutionOrder
};
*/
            [wself.lastAddedOperation addDependency:operation];
            wself.lastAddedOperation = operation;
        }
    }];

    return operation;
}
```



```objective-c

[self addProgressCallback:progressBlock completedBlock:completedBlock forURL:url createCallback:^{
//...
}
 
// 对于同一个URL，在第二次调用addProgressCallback:progressBlock用的时候，并不会执行createCallback，也就是说，保证一个URL在多次下载的时候，只进行多次回调，而不会进行多次网络请求
@{
        @"http://iamgeurl":[
                            @{
                                @"progress":progressBlock1,
                                @"completed":completedBlock1,
                            },
                            @{
                                @"progress":progressBlock2,
                                @"completed":completedBlock2,
                              },
                           ],
            //其他
}
```





##### 缓存操作 SDImageCache

特点：

- ioQueue，磁盘读写队列
- NSCache内存缓存: 1.线程安全 2.自动内存管理，及时释放内容
- 本地图片地址用MD5加密，保证了地址唯一性
- 程序进入后台或者即将推出时候，会自动清理磁盘缓存数据

**存储**

```objective-c
- (void)storeImage:(UIImage *)image recalculateFromImage:(BOOL)recalculate imageData:(NSData *)imageData forKey:(NSString *)key toDisk:(BOOL)toDisk {
    if (!image || !key) {
        return;
    }
    // if memory cache is enabled
    if (self.shouldCacheImagesInMemory) {
        NSUInteger cost = SDCacheCostForImage(image);
        /// 内存缓存
        [self.memCache setObject:image forKey:key cost:cost];
    }

    if (toDisk) { // 异步写出磁盘
        dispatch_async(self.ioQueue, ^{
            NSData *data = imageData;

            if (image && (recalculate || !data)) {
#if TARGET_OS_IPHONE
                // We need to determine if the image is a PNG or a JPEG
                // PNGs are easier to detect because they have a unique signature (http://www.w3.org/TR/PNG-Structure.html)
                // The first eight bytes of a PNG file always contain the following (decimal) values:
                // 137 80 78 71 13 10 26 10

                // If the imageData is nil (i.e. if trying to save a UIImage directly or the image was transformed on download)
                // and the image has an alpha channel, we will consider it PNG to avoid losing the transparency
                int alphaInfo = CGImageGetAlphaInfo(image.CGImage);
                BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                                  alphaInfo == kCGImageAlphaNoneSkipFirst ||
                                  alphaInfo == kCGImageAlphaNoneSkipLast);
                BOOL imageIsPng = hasAlpha;

                // But if we have an image data, we will look at the preffix
                if ([imageData length] >= [kPNGSignatureData length]) {
                    imageIsPng = ImageDataHasPNGPreffix(imageData);
                }

                if (imageIsPng) {
                    data = UIImagePNGRepresentation(image);
                }
                else {
                    data = UIImageJPEGRepresentation(image, (CGFloat)1.0);
                }
#else
                data = [NSBitmapImageRep representationOfImageRepsInArray:image.representations usingType: NSJPEGFileType properties:nil];
#endif
            }
            [self storeImageDataToDisk:data forKey:key];
        });
    }
}

.....

- (void)storeImageDataToDisk:(NSData *)imageData forKey:(NSString *)key {
    
    if (!imageData) {
        return;
    }

    if (![_fileManager fileExistsAtPath:_diskCachePath]) {
        [_fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    // get cache Path for image key
    NSString *cachePathForKey = [self defaultCachePathForKey:key];
    // transform to NSUrl
    NSURL *fileURL = [NSURL fileURLWithPath:cachePathForKey];
    NSLog(@"%@",cachePathForKey);
    
    [_fileManager createFileAtPath:cachePathForKey contents:imageData attributes:nil];
    
    // disable iCloud backup
    if (self.shouldDisableiCloud) {
        [fileURL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
    }
}
```



##### 查询

```objective-c
- (NSOperation *)queryDiskCacheForKey:(NSString *)key done:(SDWebImageQueryCompletedBlock)doneBlock {
    if (!doneBlock) {
        return nil;
    }

    if (!key) {
        doneBlock(nil, SDImageCacheTypeNone);
        return nil;
    }

    // First check the in-memory cache...
    UIImage *image = [self imageFromMemoryCacheForKey:key]; //检查内存是否有缓存
    if (image) {
        doneBlock(image, SDImageCacheTypeMemory);
        return nil;
    }

    NSOperation *operation = [NSOperation new];
    dispatch_async(self.ioQueue, ^{     // 磁盘读写队查询缓存
        if (operation.isCancelled) {
            return;
        }
        @autoreleasepool { 
            UIImage *diskImage = [self diskImageForKey:key];
            if (diskImage && self.shouldCacheImagesInMemory) {
                NSUInteger cost = SDCacheCostForImage(diskImage);
                [self.memCache setObject:diskImage forKey:key cost:cost];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                doneBlock(diskImage, SDImageCacheTypeDisk);
            });
        }
    });
    return operation;
}

- (NSString *)cachePathForKey:(NSString *)key inPath:(NSString *)path {
    NSString *filename = [self cachedFileNameForKey:key];
    return [path stringByAppendingPathComponent:filename];
}

- (NSString *)defaultCachePathForKey:(NSString *)key {
    return [self cachePathForKey:key inPath:self.diskCachePath];
}

```

```objective-c
#pragma mark SDImageCache (private)
// 简单封装了cachePathForKey:inPath
- (NSString *)defaultCachePathForKey:(NSString *)key {
    return [self cachePathForKey:key inPath:self.diskCachePath];
}
- (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
  
  // 官方封装好的加密方法
// 把str字符串转换成了32位的16进制数列（这个过程不可逆转） 存储到了r这个空间中
// 最终生成的文件名就是 "md5码"+".文件类型"
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], [[key pathExtension] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@".%@", [key pathExtension]]];

    return filename;
}
```



#### 删除

```objective-c

 // －接收到内存警告通知－清理内存操作 - clearMemory
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cleanDisk)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(backgroundCleanDisk)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];

........
  
  

          
/**
删除早于过期日期的文件（默认7天过期）,可以通过maxCacheAge属性重新设置缓存时间
如果剩余磁盘缓存空间超出最大限额(maxCacheSize)，再次执行清理操作，删除最早的文件（按照文件最后修改时间的逆序，以每次一半的递归来移除那些过早的文件，直到缓存的实际大小小于我们设置的最大使用空间，可以通过修改 maxCacheSize 来改变最大缓存大小。
*/
  // 清理过期的缓存图片
  - (void)cleanDiskWithCompletionBlock:(SDWebImageNoParamsBlock)completionBlock {    dispatch_async(self.ioQueue, ^{        // 获取存储路径
        NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];        // 获取相关属性数组
        NSArray *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey];        // This enumerator prefetches useful properties for our cache files.
        // 此枚举器预取缓存文件对我们有用的特性。  预取缓存文件中有用的属性
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtURL:diskCacheURL
                                                   includingPropertiesForKeys:resourceKeys
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                 errorHandler:NULL];        // 计算过期日期
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.maxCacheAge];        NSMutableDictionary *cacheFiles = [NSMutableDictionary dictionary];        NSUInteger currentCacheSize = 0;        // Enumerate all of the files in the cache directory.  This loop has two purposes:
        // 遍历缓存路径中的所有文件，此循环要实现两个目的
        //
        //  1. Removing files that are older than the expiration date.
        //     删除早于过期日期的文件
        //  2. Storing file attributes for the size-based cleanup pass.
        //     保存文件属性以计算磁盘缓存占用空间
        //
        NSMutableArray *urlsToDelete = [[NSMutableArray alloc] init];        for (NSURL *fileURL in fileEnumerator) {            NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];            // Skip directories. 跳过目录
            if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {                continue;
            }            // Remove files that are older than the expiration date; 记录要删除的过期文件
            NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];            if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
                [urlsToDelete addObject:fileURL];                continue;
            }            // Store a reference to this file and account for its total size.
            // 保存文件引用，以计算总大小
            NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
            currentCacheSize += [totalAllocatedSize unsignedIntegerValue];
            [cacheFiles setObject:resourceValues forKey:fileURL];
        }        // 删除过期的文件
        for (NSURL *fileURL in urlsToDelete) {
            [_fileManager removeItemAtURL:fileURL error:nil];
        }        // If our remaining disk cache exceeds a configured maximum size, perform a second
        // size-based cleanup pass.  We delete the oldest files first.
        // 如果剩余磁盘缓存空间超出最大限额，再次执行清理操作，删除最早的文件
        if (self.maxCacheSize > 0 && currentCacheSize > self.maxCacheSize) {            // Target half of our maximum cache size for this cleanup pass.
            const NSUInteger desiredCacheSize = self.maxCacheSize / 2;            // Sort the remaining cache files by their last modification time (oldest first).
            NSArray *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                            usingComparator:^NSComparisonResult(id obj1, id obj2) {                                                                return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
                                                            }];            // Delete files until we fall below our desired cache size.
            // 循环依次删除文件，直到低于期望的缓存限额
            for (NSURL *fileURL in sortedFiles) {                if ([_fileManager removeItemAtURL:fileURL error:nil]) {                    NSDictionary *resourceValues = cacheFiles[fileURL];                    NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                    currentCacheSize -= [totalAllocatedSize unsignedIntegerValue];                    if (currentCacheSize < desiredCacheSize) {                        break;
                    }
                }
            }
        }        if (completionBlock) {            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }
    });
}
```



参考: 

[一行行看SDWebImage源码(一)](http://www.jianshu.com/p/82c7f2865c92)

[一行行看SDWebImage源码(二)](http://www.jianshu.com/p/67f8daa47a10)

[iOS开源库源码解析之SDWebImage](http://blog.csdn.net/hello_hwc/article/details/51404322)

[通读SDWebImage①--总体梳理、下载和缓存](http://www.cnblogs.com/Mike-zh/p/5204240.html)

[SDWebImage源码阅读系列](http://www.cnblogs.com/polobymulberry/category/785704.html)



