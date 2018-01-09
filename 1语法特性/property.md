---
title: property
date: 2015-11-12 22:27:40
tags:
---

#### 是什么
封装实例变量，生成存取方法,由编译器自动合成

property = var+ setter + getter

```objective-c
@interface Person : NSObject
@property NSString *name;
@property NSString *lastName;
@end
//----等价于
@interface Person : NSObject
- (NSString *)name;
- (void)setName:(NSString *)name;
@end
```

#### 生成关键字种类

- 内存管理

  assign, weak,strong,copy

  ​


- 线程安全

  > atomic: 加锁， 多线程安全(安全), nonatomic:不加锁
  >
  > 相关伪代码
  >
  > ```objective-c
  > - (void)setProp:(NSString *)newValue {
  >     [_prop lock];
  >     _prop = newValue;
  >     [_prop unlock];
  > }
  > ```
  >
  > atomic 只能保证读写操作的完整性，但是并不能保证线程安全
  >
  > 试想一下这个例子
  >
  > 线程A 和线程B同时对X进行写入操作。
  >
  > 当线程A进行写操作，这时其他线程的读或者写操作会因为该操作而等待。当A线程的写操作结束后，B线程进行写操作，然后当A线程需要读操作时，却获得了在B线程中的值，这就破坏了线程安全。
  >
  > Thread A:
  >
  > ```
  > p.firstName = @"Rob";
  > ```
  >
  > Thread B:
  >
  > ```
  > p.firstName = @"Robert";
  > ```
  >
  > Thread A:
  >
  > ```objective-c
  > label.string = p.firstName;   // << uh, oh -- will be Robert
  > ```

  ​

- 读写

  readwrite, readonly

  > readonly 不合成setter方法

- 命名

  for:

  `@property (nonatomic, assign, getter = isOpen) BOOL open;`

  setter的修改方式类似，只是不太常用

参考:

[Which is threadsafe atomic or non atomic?](http://stackoverflow.com/questions/12347236/which-is-threadsafe-atomic-or-non-atomic)

[@property的前世今生](http://blog.talisk.cn/blog/2016/03/05/iOS-@property/)
