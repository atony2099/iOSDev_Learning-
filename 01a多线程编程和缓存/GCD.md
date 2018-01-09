---
title: GCD
date: 2015-10-03 15:13:11
tags:GCD
---

#### 基础概念

##### 线程安全

> **线程安全** 多个线程同时访问数据数据造成数据错乱。

> 比如一个 ArrayList 类，在添加一个元素的时候，它可能会有两步来完成：1. 在 Items[Size] 的位置存放此元素；2. 增大 Size 的值。
>
> 在[单线程](http://baike.baidu.com/view/2554947.htm)运行的情况下，如果 Size = 0，添加一个元素后，此元素在位置 0，而且 Size=1；
>
> 而如果是在多线程情况下，比如有两个线程，线程 A 先将元素1存放在位置 0。但是此时 CPU 调度线程A暂停，线程 B 得到运行的机会。线程B向此 ArrayList 添加元素2，因为此时 Size 仍然等于 0 （注意，我们假设的是添加一个元素是要两个步骤，而线程A仅仅完成了

##### 队列

> 按照FIFO执行处理处理的队列

| serial Dispatch Queue | concurrent DisPatch Queue |
| --------------------- | ------------------------- |
| 等待执行中的处理执行完(容易造成死锁)   | 不等待执行中的处理处理完              |

![](http://ohbzayk4i.bkt.clouddn.com/17-1-13/6777910-file_1484239116398_f76c.jpg)

##### Global Dispatch Queue 

Global Dispatch Queue有4个优先级，分别是：High、Default、Low、Background。

##### 任务

> 追加到队列中的任务

| 同步                 | 异步                      |
| ------------------ | ----------------------- |
| 函数等待任务处理完返回，阻塞当前线程 | 函数不等待任务处理完就立即返回，不阻塞当前线程 |



##### 

#### 多线程数据竞争(数据竞态)

![](http://ohbzayk4i.bkt.clouddn.com/17-1-13/40169187-file_1484240564312_1667d.png)

##### condition race 解决方案

- 互斥锁

  ![](http://ohbzayk4i.bkt.clouddn.com/17-1-13/71558328-file_1484242462476_147eb.png)

- 异步串行队列

  ```objective-c
  ###SDImageCache  
      if (toDisk) { // 子线程写入磁盘
              dispatch_async(self.ioQueue, ^{
                  NSData *data = imageData;
                  [self storeImageDataToDisk:data forKey:key];
              });
          }

      dispatch_async(self.ioQueue, ^{     // 子线程执读取磁盘图片
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
  ```

  ​

- dispatch_barrier_async

  ![](http://ohbzayk4i.bkt.clouddn.com/17-1-13/78424432-file_1484239123947_16666.png)






栅栏：屏蔽当前任务前后的任务，隔离当前

保证单读多写



#### 线程死锁

>  简单理解: 线程卡在那边，无法执行下去

```
NSLog(@"block1"); // 任务1
dispatch_sync(dispatch_get_main_queue(), ^{
    NSLog(@"block2"); // 任务2
});
NSLog(@"block1"); // 任务3
```

![](http://ohbzayk4i.bkt.clouddn.com/17-1-13/88536677-file_1484244482274_15746.png)





#### dispatch group

同时发起网络请求，但是我们需要在三个网络请求都成功获取数据后才执行do sth

```
NSArray *urlStrings = @[ @"http://octree.me", @"http://google.com", @"http://github.com" ];

for(NSString urlString in urlStrings) {  
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {  
        //do sth 
        
        
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
}];
}
```

> Grouping blocks allows for aggregate synchronization. Your application can submit multiple blocks and track when they all complete, even though they might run on different queues. This behavior can be helpful when progress can’t be made until all of the specified tasks are complete.

dispatch_group提供了多个block同步的机制，可以再多个不同bloc都执行完后再去执行指定的任务

相关函数: 

dispatch_group_enter:

> Explicitly indicates that a block has entered the group.Calling this function increments the current count of outstanding tasks in the group

dispatch_group_leave : 

> Explicitly indicates that a block in the group has completed.Calling this function decrements the current count of outstanding tasks in the group

dispatch_group_notify

> Schedules a block object to be submitted to a queue when a group of previously submitted block objects have completed.



```
NSArray *urlStrings = @[ @"http://octree.me", @"http://google.com", @"http://github.com" ];
dispatch_group_t requestGroup = dispatch_group_create(); 
for(NSString urlString in urlStrings) {
  dispatch_group_enter(requestGroup);   //当前的任务加入group
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
      NSLog(@"Success");
      dispatch_group_leave(requestGroup);
   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      NSLog(@"Error: %@", error);
      dispatch_group_leave(requestGroup); // 当前的任务已经执行完
  }];
}

dispatch_group_notify(requestGroup, dispatch_get_main_queue(), ^{ // 上面的
    //doSomething
});
```

#### vs NSOperation

1. 更方便设置任务的依赖

   ```
   /1.任务一：下载图片
   NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
       NSLog(@"下载图片 - %@", [NSThread currentThread]);
       [NSThread sleepForTimeInterval:1.0];
   }];
   //2.任务二：打水印
   NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
       NSLog(@"打水印   - %@", [NSThread currentThread]);
       [NSThread sleepForTimeInterval:1.0];
   }];
   //3.任务三：上传图片
   NSBlockOperation *operation3 = [NSBlockOperation blockOperationWithBlock:^{
       NSLog(@"上传图片 - %@", [NSThread currentThread]);
       [NSThread sleepForTimeInterval:1.0];
   }];
   //4.设置依赖
   [operation2 addDependency:operation1];      //任务二依赖任务一
   [operation3 addDependency:operation2];      //任务三依赖任务二
   //5.创建队列并加入任务
   NSOperationQueue *queue = [[NSOperationQueue alloc] init];
   [queue addOperations:@[operation3, operation2, operation1] waitUntilFinished:NO];

   ```

2. 更加方便监听任务的状态 && 取消

   ```
   ####NSOperation
   BOOL executing; //判断任务是否正在执行
   BOOL finished; //判断任务是否完成
   void (^completionBlock)(void); //用来设置完成后需要执行的操作
   - (void)cancel; //取消任务
   - (void)waitUntilFinished; //阻塞当前线程直到此任务执行完毕
   #### NSOperationQueue
   NSUInteger operationCount; //获取队列的任务数
   - (void)cancelAllOperations; //取消队列中所有的任务
   - (void)waitUntilAllOperationsAreFinished; //阻塞当前线程直到此队列中的所有任务执行完毕
   [queue setSuspended:YES]; // 暂停queue
   [queue setSuspended:NO]; // 继续queu
   ```

   ​



#### GCD底层实现

![](https://objccn.io/images/issues/issue-2/gcd-queues.png)



基于xun内核实现的



参考:

[深入理解 GCD（一）](http://blog.jobbole.com/66866/)

[并发编程：API 及挑战](https://objccn.io/issue-2-1/#Priority-Inversion)

[iOS开发：深入理解GCD 第二篇（dispatch_group、dispatch_barrier、基于线程安全的多读单写](http://www.cnblogs.com/ziyi--caolu/p/4900650.html)









