---
title: load && initialize
date: 2015-12-12 16:32:39
tags:

---

#### load && initialize 

- load

> Invoked whenever a class or category is added to the Objective-C runtime; implement this method to perform class-specific behavior upon loading.
>
> The load message is sent to classes and categories that are both dynamically loaded and statically linked, but only if the newly loaded class or category implements a method that can respond.

从上面的描述可以看出这个方法调用的时机很早，在类(分类)被加载到runtime的时候就会调用，同时只有类实现了这个方法才能被响应。

- initialize

> The runtime sends initialize to each class in a program just before the class, or any class that inherits from it, is sent its first message from within the program. 

不同于load，initialize只有在类或者它的子类第一次接收到消息之前才会调用,相当于懒加载。

#### 代码

```objective-c
int main(int argc, char * argv[]) {
    @autoreleasepool {
        NSLog(@"%s",__func__);
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}

@interface Animal : NSObject

@end

@implementation Animal
+ (void)load{
    NSLog(@"%s",__func__);
}
+ (void)initialize{
    [super initialize];
    NSLog(@"%s %@",__func__,[self class]);
}
@end


@interface Dog : Animal

@end

@implementation Dog
+ (void)load{
    NSLog(@"%s ",__func__);
}
+ (void)initialize{
    [super initialize];
    NSLog(@"%s ",__func__);
}
@end
```

在main.m文件里执行上述代码，可以输出

```objective-c
 +[Animal load]
 +[Dog load] 
 main
```

可以看出在没有主动对类执行操作情况下，load会默认执行，并且在main函数之前执行

```objective-c
@interface Animal : NSObject

@end

@implementation Animal
+ (void)load{
    NSLog(@"%s ",__func__);
}
  
+ (void)initialize {
    NSLog(@"%s %@",__func__,[self class]);
}

@end

@interface Dog : Animal

@end

@implementation Dog

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    Dog *dog = [[Dog alloc] init];
}
@end
```

执行结果: 

```objective-c
+[Animal load]
+[Animal initialize] Animal
+[Animal initialize] Dog
```

从上面我们可以看出initialize明显的一个特点是当子类没有实现的时候，它会主动调用父类的方法，而load并没有这一特性，为了解释这一特性，我们得从runtime源码层面剖析: 

load方法的调用核心代码

```objective-c
    // Call all +loads for the detached list.
    for (i = 0; i < used; i++) {
        Class cls = classes[i].cls;
        load_method_t load_method = (load_method_t)classes[i].method;
        if (!cls) continue;

        if (PrintLoading) {
            _objc_inform("LOAD: +[%s load]\n", cls->nameForLogging());
        }
        (*load_method)(cls, SEL_load);
    }
```

这段代码循环调用所有类的 +load 方法。**注意**，这里是（调用分类的 +load 方法也是如此）直接使用函数内存地址的方式 `(*load_method)(cls, SEL_load);` 对 +load 方法进行调用的，而不是使用发送消息 `objc_msgSend` 的方式。

这样的调用方式就使得 +load 方法拥有了一个非常有趣的特性，那就是子类、父类和分类中的 +load 方法的实现是被区别对待的。也就是说如果子类没有实现 +load 方法，那么当它被加载时 runtime 是不会去调用父类的 +load 方法的。同理，当一个类和它的分类都实现了 +load 方法时，两个方法都会被调用。



```objective-c
void _class_initialize(Class cls)
{
    ...
    Class supercls;
    BOOL reallyInitialize = NO;

    // Make sure super is done initializing BEFORE beginning to initialize cls.
    // See note about deadlock above.
    supercls = cls->superclass;
    if (supercls  &&  !supercls->isInitialized()) {
        _class_initialize(supercls);
    }

    // Try to atomically set CLS_INITIALIZING.
    monitor_enter(&classInitLock);
    if (!cls->isInitialized() && !cls->isInitializing()) {
        cls->setInitializing();
        reallyInitialize = YES;
    }
    monitor_exit(&classInitLock);

    if (reallyInitialize) {
        // We successfully set the CLS_INITIALIZING bit. Initialize the class.

        // Record that we're initializing this class so we can message it.
        _setThisThreadIsInitializingClass(cls);

        // Send the +initialize message.
        // Note that +initialize is sent to the superclass (again) if 
        // this class doesn't implement +initialize. 2157218
        if (PrintInitializing) {
            _objc_inform("INITIALIZE: calling +[%s initialize]",
                         cls->nameForLogging());
        }

        ((void(*)(Class, SEL))objc_msgSend)(cls, SEL_initialize);

        if (PrintInitializing) {
            _objc_inform("INITIALIZE: finished +[%s initialize]",
    ...
}
```

这段代码有两个关键点: 

-  入参的父类进行了递归调用，以确保父类优先于子类初始化
-  runtime 使用了发送消息 `objc_msgSend`的方式对 +initialize 方法进行调用。也就是说 +initialize 方法的调用与普通方法的调用是一样的，走的都是发送消息的流程。换言之，如果子类没有实现 +initialize 方法，那么继承自父类的实现会被调用；如果一个类的分类实现了 +initialize 方法，那么就会对这个类中的实现造成覆盖




#### 使用场景

- load

  > method swizzling

#### 总结

- 两者在runtime都是递归调用，父类先于子类被调用
- load根据函数地址发送，(分类.子类，父类调用分开)  initialise(懒加载) meg_send发送 (子类没有实现会查找父亲的方法列表，分类覆盖所属类的实现)

|                   | +load          | +initialize      |
| ----------------- | -------------- | ---------------- |
| 调用时机              | 被添加到 runtime 时 | 收到第一条消息前，可能永远不调用 |
| 调用顺序              | 父类->子类->分类     | 父类->子类           |
| 调用次数              | 1次             | 多次               |
| 若自身未定义，是否沿用父类的方法？ | 否              | 是                |
| 分类中的实现            | 类和分类都执行        | 覆盖类中的方法，只执行分类的实现 |

参考: 

[Objective-C +load vs +initialize](http://blog.leichunfeng.com/blog/2015/05/02/objective-c-plus-load-vs-plus-initialize/)