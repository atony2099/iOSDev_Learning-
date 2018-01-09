---
title: copy解析
date: 2016-10-29 19:48:20
tags: 
---

文章来源: [Objective-C copy，看我就够了](http://ios.jobbole.com/91611/?utm_source=blog.jobbole.com&utm_medium=relatedPosts)

#### copy 使用场景

>  Copying is done mostly so the copy can be modified or moved, or the current value preserved. If either of these is unneeded, a reference to the original data is sufficient and more efficient, as no copying occurs.
>
> In Objective-C, the methods copy and mutableCopy are inherited by all objects and intended for performing copies; the latter is for creating a mutable type of the original object. These methods in turn call the copyWithZone and mutableCopyWithZone methods, respectively, to perform the copying. An object must implement the corresponding copyWithZone method to be copyable.

#### deep copy && shallow copy

#### ![](https://developer.apple.com/library/content/documentation/General/Conceptual/DevPedia-CocoaCore/Art/object_copying_2x.png) 

- 浅复制：只复制对象的指针
- 深复制:  会创建一个新的对象


#### Foundation框架非集合类的copy

- 对immutableObject，即不可变对象，执行copy，会得到不可变对象，并且是浅copy。
- 对immutableObject，即不可变对象，执行mutableCopy，会得到可变对象，并且是深copy。
- 对mutableObject，即可变对象，执行copy，会得到不可变对象，并且是深copy。
- 对mutableObject，即可变对象，执行mutableCopy，会得到可变对象，并且是深copy。

#### 自定义类的copy

```objective-c
// Model定义，copyWithZone第一种实现（浅copy）
@interface Model1 : NSObject<NSCopying>
@property (nonatomic, assign) NSInteger a;
@end
 
@implementation Model1
- (id)copyWithZone:(NSZone *)zone {
    return self;
}
@end
 
// Model定义，copyWithZone第二种实现（深copy）
@interface Model1 : NSObject 
@property (nonatomic, assign) NSInteger a;
@end
 
@implementation Model1
- (id)copyWithZone:(NSZone *)zone {
    Model1 *model = [[Model1 allocWithZone:zone] init];
    model.a = self.a;
    return model;
}
@end
 
// 分别选择上述两种model进行指针打印。
Model1 *model = [[Model1 alloc] init];
Model1 *copyModel = [model copy];
NSLog(@"%p", model);
NSLog(@"%p", copyModel);
```

执行结果

```c
// 对应上述一，可见实现了浅copy
2016-10-21 11:12:03.149 Memory[67723:5636292] 0x60000000c9d0
2016-10-21 11:12:03.149 Memory[67723:5636292] 0x60000000c9d0
// 对应上述二，可见实现了深copy
2016-10-21 11:16:46.803 Memory[67752:5640133] 0x60800001df00
2016-10-21 11:16:46.803 Memory[67752:5640133] 0x60800001def0

```

> 深浅复制：一切就看你怎么实现NSCopying协议中的copyWithZone:方法。

#### Foundation框架集合对象

##### 单层深复制

>与非集合框架类一样，对不可变变集合执行复制即是浅复制



##### 单层深复制

![](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/Collections/Art/CopyingCollections_2x.png)



```objective-c
NSArray *arr = [NSArray arrayWithObjects:@"1", nil];
NSArray *copyArr = [arr mutableCopy];
 
NSLog(@"%p", arr);
NSLog(@"%p", copyArr);
 
// 打印arr、copyArr内部元素进行对比
NSLog(@"%p", arr[0]);
NSLog(@"%p", copyArr[0]);

// 虽然集合的对象的地址改变，但集合元素地址还是不变，属于浅复制
2016-10-21 11:32:27.157 Memory[67801:5649757] 0x6000000030d0
2016-10-21 11:32:27.157 Memory[67801:5649757] 0x600000242e50
2016-10-21 11:32:27.157 Memory[67801:5649757] 0x10dd811b0
2016-10-21 11:32:27.157 Memory[67801:5649757] 0x10dd811b0
```



#### 深复制(双层)

这里的双层指的是完成了NSArray对象和NSArray容器内对象的深copy（为什么不说完全，是因为无法处理NSArray中还有一个NSArray这种情况）。

```objective-c
// 随意创建一个NSMutableString对象
NSMutableString *mutableString = [NSMutableString stringWithString:@"1"];
// 随意创建一个包涵NSMutableString的NSMutableArray对象
NSMutableString *mutalbeString1 = [NSMutableString stringWithString:@"1"];
NSMutableArray *mutableArr = [NSMutableArray arrayWithObjects:mutalbeString1, nil];
// 将mutableString和mutableArr放入一个新的NSArray中
NSArray *testArr = [NSArray arrayWithObjects:mutableString, mutableArr, nil];
// 通过官方文档提供的方式创建copy
NSArray *testArrCopy = [[NSArray alloc] initWithArray:testArr copyItems:YES];
 
// testArr和testArrCopy指针对比
NSLog(@"%p", testArr);
NSLog(@"%p", testArrCopy);
 
// testArr和testArrCopy中元素指针对比
// mutableString对比
NSLog(@"%p", testArr[0]);
NSLog(@"%p", testArrCopy[0]);
// mutableArr对比
NSLog(@"%p", testArr[1]);
NSLog(@"%p", testArrCopy[1]);
 
// mutableArr中的元素对比，即mutalbeString1对比
NSLog(@"%p", testArr[1][0]);
NSLog(@"%p", testArrCopy[1][0]);

// 这里可以发现，copy后，只有mutableArr中的mutalbeString1指针地址没有变化。而testArr的指针和testArr中的mutableArr、mutableString的指针地址均发生变化。所以称之为双层深复制。
2016-10-21 12:03:15.549 Memory[67855:5668888] 0x60800003c7a0
2016-10-21 12:03:15.549 Memory[67855:5668888] 0x60800003c880
2016-10-21 12:03:15.549 Memory[67855:5668888] 0x608000260540
2016-10-21 12:03:15.550 Memory[67855:5668888] 0xa000000000000311
2016-10-21 12:03:15.550 Memory[67855:5668888] 0x60800005d610
2016-10-21 12:03:15.550 Memory[67855:5668888] 0x60800000d2e0
2016-10-21 12:03:15.550 Memory[67855:5668888] 0x608000260980
2016-10-21 12:03:15.550 Memory[67855:5668888] 0x608000260980

```



#### 完全深复制

```objective-c
// 随意创建一个NSMutableString对象
NSMutableString *mutableString = [NSMutableString stringWithString:@"1"];
// 随意创建一个包涵NSMutableString的NSMutableArray对象
NSMutableString *mutalbeString1 = [NSMutableString stringWithString:@"1"];
NSMutableArray *mutableArr = [NSMutableArray arrayWithObjects:mutalbeString1, nil];
// 将mutableString和mutableArr放入一个新的NSArray中
NSArray *testArr = [NSArray arrayWithObjects:mutableString, mutableArr, nil];
// 通过归档、解档方式创建copy
NSArray *testArrCopy = [NSKeyedUnarchiver unarchiveObjectWithData:
                            [NSKeyedArchiver archivedDataWithRootObject:testArr]];;

// testArr和testArrCopy指针对比
NSLog(@"%p", testArr);
NSLog(@"%p", testArrCopy);

// testArr和testArrCopy中元素指针对比
// mutableString对比
NSLog(@"%p", testArr[0]);
NSLog(@"%p", testArrCopy[0]);
// mutableArr对比
NSLog(@"%p", testArr[1]);
NSLog(@"%p", testArrCopy[1]);

// mutableArr中的元素对比，即mutalbeString1对比
NSLog(@"%p", testArr[1][0]);
NSLog(@"%p", testArrCopy[1][0])
 
  // 结果分析
2016-10-21 12:19:34.022 Memory[67887:5677318] 0x60800002db00
2016-10-21 12:19:34.022 Memory[67887:5677318] 0x60800002dc20
2016-10-21 12:19:34.022 Memory[67887:5677318] 0x608000260400
2016-10-21 12:19:34.023 Memory[67887:5677318] 0x6080002603c0
2016-10-21 12:19:34.023 Memory[67887:5677318] 0x608000051d90
2016-10-21 12:19:34.023 Memory[67887:5677318] 0x6080000521e0
2016-10-21 12:19:34.023 Memory[67887:5677318] 0x608000260600
2016-10-21 12:19:34.023 Memory[67887:5677318] 0x6080002606c0
```



#### copy 与关键字

```objective-c
// 首先分别给出copy和strong修饰的属性，以NSString举例
// 1、strong
@property (nonatomic, strong) NSString *str;
// 2、copy
@property (nonatomic, copy) NSString *str;
 
// 分别对1和2执行下述代码
NSMutableString *mutableStr = [NSMutableString stringWithFormat:@"123"];
self.str = mutableStr;
[mutableStr appendString:@"456"];
NSLog(@"%@", self.str);
NSLog(@"%p", self.str);
NSLog(@"%@", mutableStr);
NSLog(@"%p", mutableStr);
 
// 结果1
2016-10-21 14:08:46.657 Memory[68242:5714288] 123456
2016-10-21 14:08:46.657 Memory[68242:5714288] 0x608000071040
2016-10-21 14:08:46.657 Memory[68242:5714288] 123456
2016-10-21 14:08:46.657 Memory[68242:5714288] 0x608000071040
// 结果2
2016-10-21 14:11:16.879 Memory[68264:5716282] 123
2016-10-21 14:11:16.880 Memory[68264:5716282] 0xa000000003332313
2016-10-21 14:11:16.880 Memory[68264:5716282] 123456
2016-10-21 14:11:16.880 Memory[68264:5716282] 0x60000007bbc0

```

> Foundation框架 中有可变与不可变的类如NSString，NSNumber,NSAarray ,通常使用copy关键字修饰
>
> 原因: 由于OC的多态，不可变的对象指针可以指向可变对象，这会导致声明为不可变的对象属性遭到篡改，不安全



