---
title: weak strong dance
date: 2016-05-25 20:51:37
tags:
---

#### __weak

在ARC环境下的，每个block在创建时，编译器会对里面用到的所有对象自动增加一个reference count,如下 Block 会 retain ‘self’，而 ‘self‘ 又 retain 了 Block。

```objective-c
__weak typeof(self) weakSelf = self; 
    self.block = ^{
      	if(strongSelf) {
           [strongSelf description];
      	}
    };
```

weakSelf是为了block不持有self，避免循环引用，而再声明一个strongSelf是因为一旦进入block执行，就不允许self在这个执行过程中释放。block执行完后这个strongSelf会自动释放，没有循环引用问题。

#### __strong 

单纯的加weak 还是由问题，试想一下，如果这个block在子线程执行，block执行的是一个很长的代码，在A节点self还在，在B节点，self被销毁了。

```objective-c
weak typeof__(self) weakSelf = self; //retainCount  = 1;

 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

    [weakSelf doSomething]; // A节点self还在,retainCount = 1;
   [weakSelf doSomtThing];// B节点self被release，retainCount = 0；执行执行的逻辑是不完整的
});
```

引入block:

```objective-c
weak typeof__(self) weakSelf = self; //retainCount  = 1;

 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     __strong typeof(self) strongSelf = weakSelf; //此时retainCount = 2 
    [weakSelf doSomething]; // A节点self还在,retainCount = 2;
   [weakSelf doSomtThing];// B节点self被release，retainCount = 1；执行执行的逻辑是不完整的
});
weakSelf；// weakSelf的作用域大于self,此时self 的retainCount = 0;
 

```

> strog - weak配合 能保证block代码能保证在代码执行过程中持有self，保证代码执行完整



#### 更进一步的判断

如果在block被调用的时候self已经是nil的情况下呢？

```objective-c
self;// 初始self 假设当前的self的retainCount = 1；
 __weak typeof(self) weakSelf = self; //此时retainCount = 1;
    self.block = ^{
       __strong typeof(self) strongSelf = weakSelf;
        __strong typeof(self) strongSelf = weakSelf; //此时retainCount = ??
      	if(strongSelf) {
           [strongSelf description];
      	}
    };
```

clang转换后

```c
  struct __TestBlock__test_block_impl_0 {
  struct __block_impl impl;
  struct __TestBlock__test_block_desc_0* Desc;
  TestBlock *const __weak weakSelf;  //  weak指针，并没有拥有self
  __TestBlock__test_block_impl_0(void *fp, struct __TestBlock__test_block_desc_0 *desc, TestBlock *const __weak _weakSelf, int flags=0) : weakSelf(_weakSelf) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

// Block的c语言实现函数
static void __TestBlock__test_block_func_0(struct __TestBlock__test_block_impl_0 *__cself) {
// ---假设block函数回调的时候，self已经被释放;
  //  由于block 并没有持有self，当子线程的block被延迟回调后，此时self值是nil
  	TestBlock *const __weak weakSelf = __cself->weakSelf; // bound by copy
  	//  对block 再retain已经太迟了
        __attribute__((objc_ownership(strong))) typeof(self) strongSelf = weakSelf;
        ((id (*)(id, SEL))(void *)objc_msgSend)((id)strongSelf, sel_registerName("description"));
    }
```

综上所示，weak - strong没有真正实现block对对象的拥有，**根本原因在于 block对对象的retain 发生在 block函数被调用后，若此时self已经是nil，block也无能为力 **

更规范的做法: 

```objective-c
 	__weak typeof(self) weakSelf = self; //此时retainCount = 1;
    self.block = ^{
        __strong typeof(self) strongSelf = weakSelf; 
      	if(strongSelf) {
           [strongSelf description]; 
      	}
    };
```



####   ReactiveCocoa的实现

```objective-c
@weakify
    self.block = ^{
        @strongify 
      	if(self) {
           [strongSelf description];
      	}
    };
```

@weakify @strongify 是ReactiveCocoa宏定义，简化后相当于

```objective-c
__weak __typeof(self) self_weak_ = (self);
    self.block = ^{
    __strong __typeof__(self) self = self_weak_;
     if(self) {
   	 	[self description];
     }
}];
```



[神秘的 @weakify 和 @strongify](http://devliu.com/2016/04/14/%E7%A5%9E%E7%A7%98%E7%9A%84-weakify%E5%92%8C-strongify/)

[Weak-Strong-Dance 真的安全吗？](https://gold.xitu.io/post/586e37f11b69e60063070d2c)





