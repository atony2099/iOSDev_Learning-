---
title: nonatomic VS atomic
date: 2016-02-08 01:26:58
tags:
---

stackoverflow上关于这个问题的讨论:[What's the difference between the atomic and nonatomic attributes?](http://stackoverflow.com/questions/588866/whats-the-difference-between-the-atomic-and-nonatomic-attributes)

主要在于他们生成的getter 和setter方法有所不同。

对于atomic关键字，相关伪代码如下:

```objective-c
- (UITextField *) userName {
    
    @synchronized(self) {
       return _userName;
    }
}

- (void) setUserName:(UITextField *)userName {
    @synchronized(self) {
      _userName = userName;
    }
}
```

 也就是通过加锁来保证线程安全，能避免线程分配竞争，保证数据操作的完整性

更具体例子如下:

```
@property (atomic)CGRect domain;
```

![](https://www.bignerdranch.com/img/blog/2013/10/puppyrect-1.png)

假如你需要在两条线程上修改domin，如下

> ```
> <b>thread 1:</b> puppy.domain = CGRectMake (1.0, 2.0, 3.0, 4.0);
> <b>thread 2:</b> puppy.domain = CGRectMake (10.0, 20.0, 30.0, 40.0);
> ```

你只会得到两种结果:

![](https://www.bignerdranch.com/img/blog/2013/10/puppyrect-3.png)

或者：

![](https://www.bignerdranch.com/img/blog/2013/10/puppyrect-4.png)

而不会出现:

![](https://www.bignerdranch.com/img/blog/2013/10/puppyrect-2.png)

这种混合的状态。

所以我们可以说atomic是一种线程安全的机制，但要注意这种线程安全是局部的，之所以这样说，我们还是来看一个例子更直观：

假如puppy有三个成员变量，那我们在A线程设置它的值

```
puppy.name = @"Hoover";
puppy.domain = CGRectMake (1.0, 2.0, 3.0, 4.0);
puppy.housebroken = NO;
```

在b线程设置它的值

```
puppy.name = @"Rumpelstiltskin";
puppy.domain = CGRectMake (1.0, 2.0, 3.0, 4.0);
puppy.housebroken = YES;
```

我们有可能得到

```objective-c
puppy.name = @"Hoover";
puppy.domain = CGRectMake (10.0, 20.0, 30.0, 40.0);
puppy.housebroken = NO;
```

解决方案

```
[P lock] // thread a excute
puppy.name = @"Hoover";
puppy.domain = CGRectMake (1.0, 2.0, 3.0, 4.0);
puppy.housebroken = NO;
[p unlock]
// thread b now can excute 
puppy.name = @"Hoover";
puppy.domain = CGRectMake (10.0, 20.0, 30.0, 40.0);
puppy.housebroken = NO;

```





这样一组结果，这组数据是错误的。所以单纯靠atomic并不能保证真正的线程安全。

参考:[Property Values](https://www.bignerdranch.com/blog/property-values/)