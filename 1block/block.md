---
title:深入block底层
date: 2016-09-19 17:14:18
tags:block
---



![](http://ohbzayk4i.bkt.clouddn.com/17-1-16/78897982-file_1484539845235_1139c.png)

#### 基础概念

##### 上下文

>  每一段程序都有很多外部变量。一旦你的一段程序有了外部变量，这段程序就不完整，不能独立运行。你为了使他们运行，就要给所有的外部变量一个一个写一些值进去。这些值的集合就叫上下文。

譬如说在C++的lambda表达是里面，譬如说在C++的lambda表达是里面，\[写在这里的就是上下文](int a, int b){ ... }。

##### 闭包

>  闭包: 函数+他所处上下文环境
>
>  **a closure is a [record](https://en.wikipedia.org/wiki/Record_(computer_science)) storing a [function](https://en.wikipedia.org/wiki/Function_(computer_science))[[a\]](https://en.wikipedia.org/wiki/Closure_(computer_programming)#cite_note-1)together with an environment**:[[1\]](https://en.wikipedia.org/wiki/Closure_(computer_programming)#cite_note-2) a mapping associating each [free variable](https://en.wikipedia.org/wiki/Free_variable) of the function (variables that are used locally, but defined in an enclosing scope) with the [value](https://en.wikipedia.org/wiki/Value_(computer_science)) or [reference](https://en.wikipedia.org/wiki/Reference_(computer_science)) to which the name was bound when the closure was created.[[b\]](https://en.wikipedia.org/wiki/Closure_(computer_programming)#cite_note-3) A closure—unlike a plain function—allows the function to access those *captured variables* through the closure's copies of their values or references, even when the function is invoked outside their scope.
>
>  - 程序= 代码 + 数据 ：[知乎](https://www.zhihu.com/question/24084277)
>
>    将数据保存起来，以后再使用，会觉得很自然。但将代码保持起来，以后再使用，很多人会觉得很别扭，难以理解。都是因为还没有过那道槛。
>
>    代码指令执行时候，会处于一定的环境，单纯将代码保存下来，还是不够的，需要将代码所处的环境也保存下来。闭包其实是，将代码跟代码闭包从某个角度来说，也是数据，当然也可以传递，从一个函数传递到另一个函数，也可以保持下来，以后再调用。
>
>    因为将环境也保持下来了，以后调用的时候，就还原当时的情况，延迟执行，就很容易，很自然地实现了所处于的环境做为一个整体来看待。周围的环境，表现为代码所使用的数据。在有些语言中，这个概念叫代码块（block），匿名函数(lambda)等等。
>
>    ​



*JS例子*

```javascript
　　function f1(){

　　　　var n=999;

　　　　nAdd=function(){n+=1}

　　　　function f2(){

　　　　　　alert(n);

　　　　}

　　　　return f2;

　　}

　　var result=f1();

　　result(); // 999

　　nAdd();

　　result(); // 1000
```

result实际上就是闭包f2函数。它一共运行了两次，第一次的值是999，第二次的值是1000。这证明了，函数f1中的局部变量n一直保存在内存中，并没有在f1调用后被自动清除。

为什么会这样呢？原因就在于=f1是f2的父函数，而f2被赋给了一个全局变量，这导致f2始终在内存中，而f2的存在依赖于f1，因此f1也始终在内存中，不会在调用结束后，被垃圾回收机制（garbage collection）回收。

#### block实现

>  block 实际上就是 Objective-C 语言对于闭包的实现。

block数据结构定义如下

```
struct __block_impl
{
    void *isa;
    int Flags;
    int Reserved;
    void *FuncPtr;
};
```



1. isa 指针，所有对象都有该指针，用于实现对象相关的功能。
2. flags，用于按 bit 位表示一些 block 的附加信息，本文后面介绍 block copy 的实现代码可以看到对该变量的使用。
3. reserved，保留变量。
4. FuncPtr函数指针，指向 Block 要执行的函数

> “*Blocks are Objective-C objects, which means they can be added to collections like NSArray or NSDictionary.* ”

#### block的结构   

```c
/************* Objective-C 源码 *************/
int main()
{
    void (^blk)(void) = ^{ printf("Block\n"); }; 
    blk();
    return 0;
}

```

使用clang -rewrite-objc  翻译后

```c
struct __block_impl
{
    void *isa;
    int Flags;
    int Reserved;
    void *FuncPtr;
};
struct __main_block_impl_0
{
    struct __block_impl impl;
    struct __main_block_desc_0* Desc;
    __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0)
    {
        impl.isa = &_NSConcreteStackBlock;
        impl.Flags = flags; // 函数指针
        impl.FuncPtr = fp;
        Desc = desc;
    }
};
static void __main_block_func_0(struct __main_block_impl_0 *__cself)
{
    printf("Block\n");
}
static struct __main_block_desc_0
{
    size_t reserved;
    size_t Block_size;
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0) };
int main()
{
    void (*blk)(void) = (void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA); // 构造函数 使用__main_block_func_0  __main_block_desc_0 初始化block
  	// 使用
    ((void (*)(__block_impl *))((__block_impl *)blk)->FuncPtr)((__block_impl *)blk);
    return 0;
}

```

> 这段代码有两个关键点
>
> - > 通过block使用的匿名函数被转换为普通的C语言函数__main_block_func_0
>   >
>   > ^{ printf("Block\n"); }; 
>   >
>   > ------>>
>   >
>   > static void __main_block_func_0(struct __main_block_impl_0 *__cself)
>   > {
>   > ​    printf("Block\n");
>   > }
>
> - > __main_block_func_0 函数的指针被赋值给block的成员变量FuncPtr



block 可以表示为以下结构

```c
struct __main_block_impl_0
{
   	void *isa; // block实例所指向的类对象
    int Flags; 
    int Reserved;
    void *FuncPtr; // 函数指针
    struct __main_block_desc_0* Desc;
};

```



#### block 获取局部变量

```c
/************* 使用 __block 的源码 *************/
int main()
{
    int intValue = 1;
    void (^blk)(void) = ^{ printf("intValue = %d\n", intValue); };
    blk();
    return 0;
}
```

```c
/************* 使用 clang 翻译后如下 *************/
struct __block_impl
{
    void *isa;
    int Flags;
    int Reserved;
    void *FuncPtr;
};
struct __main_block_impl_0
{
    struct __block_impl impl;
    struct __main_block_desc_0* Desc;
    int intValue;  //追加成员变量
    __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int _intValue, int flags=0) : intValue(_intValue)
    {
        impl.isa = &_NSConcreteStackBlock;
        impl.Flags = flags;
        impl.FuncPtr = fp;
        Desc = desc;
    }
};
static void __main_block_func_0(struct __main_block_impl_0 *__cself)
{
    int intValue = __cself->intValue; // bound by copy
    printf("intValue = %d\n", intValue);
}
static struct __main_block_desc_0
{
    size_t reserved;
    size_t Block_size;
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};
int main()
{
    int intValue = 1;
    void (*blk)(void) = (void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, intValue);
    ((void (*)(__block_impl *))((__block_impl *)blk)->FuncPtr)((__block_impl *)blk);
    return 0;
}
```

>   这段代码有两个关键点
>
>   - block引用外部的成员变量时候block结构体会追加新的成员变量
>
>     struct __main_block_impl_0
>     {
>     ​    struct __block_impl impl;
>     ​    struct __main_block_desc_0* Desc;
>     ​    int intValue;  
>
>     }
>
>   - block获取外部变量的值只是简单的赋值，即将外部变量的值拷贝给内部相对应的成员变量之后，block的成员变量intValue和外部的intValue就没有关系了





#### block 获取外部__block的局部变量

```c
/************* 使用 __block 的源码 *************/
int main()
{
    __block int intValue = 0;
    void (^blk)(void) = ^{
        intValue = 1;
    };
    return 0;
}
```

```c
/************* 使用 clang 翻译后如下 *************/
struct __block_impl
{
    void *isa;
    int Flags;
    int Reserved;
    void *FuncPtr;
};
struct __Block_byref_intValue_0
{
    void *__isa;
    __Block_byref_intValue_0 *__forwarding;
    int __flags;
    int __size;
    int intValue;
};
struct __main_block_impl_0
{
    struct __block_impl impl;
    struct __main_block_desc_0* Desc;
    __Block_byref_intValue_0 *intValue; // by ref
    __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, __Block_byref_intValue_0 *_intValue, int flags=0) : intValue(_intValue->__forwarding)
    {
        impl.isa = &_NSConcreteStackBlock;
        impl.Flags = flags;
        impl.FuncPtr = fp;
        Desc = desc;
    }
};
static void __main_block_func_0(struct __main_block_impl_0 *__cself)
{
    __Block_byref_intValue_0 *intValue = __cself->intValue; // bound by ref
    (intValue->__forwarding->intValue) = 1;
}
static void __main_block_copy_0(struct __main_block_impl_0 *dst, struct __main_block_impl_0 *src)
{
    _Block_object_assign((void*)&dst->intValue, (void*)src->intValue, 8/*BLOCK_FIELD_IS_BYREF*/);
}
static void __main_block_dispose_0(struct __main_block_impl_0 *src)
{
    _Block_object_dispose((void*)src->intValue, 8/*BLOCK_FIELD_IS_BYREF*/);
}
static struct __main_block_desc_0。
{
    size_t reserved;
    size_t Block_size;
    void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
    void (*dispose)(struct __main_block _impl_0*);
} __main_block_desc_0_DATA = {  0, 
                                sizeof(struct __main_block_impl_0), 
                                __main_block_copy_0, 
                                __main_block_dispose_0
                             };
int main()
{
     __Block_byref_intValue_0 intValue = {
        (void*)0, // 对象指针
        (__Block_byref_intValue_0 *)&intValue,  //指向自己的指针
        0, 		// 标志位变量
        sizeof(__Block_byref_intValue_0), // 结构体大小
        1  //外部变量
    };
    void (*blk)(void) = (void (*)()) &__main_block_impl_0   \
                (
                    (void *)__main_block_func_0,            \
                    &__main_block_desc_0_DATA,              \
                    (__Block_byref_intValue_0 *)&intValue,  \
                    570425344                               \
                );
    return 0;
}
```

**对于__block变量**

> 1. block结构体追加一个新的成员变量 __Block_byref_intValue_0类型的结构体
> 2. 自动变量包装成__Block_byref_intValue_0结构体实例，原来的自动变量被转换为该结构体的成员变量，
> 3. block通过自身的__Block_byref_intValue0 成员变量上的__forwarding对成员变量val进行访问.这个成员变量指向的就是原来的自动变量val

![](http://ohbzayk4i.bkt.clouddn.com/17-1-18/1195180-file_1484723235733_59f0.png)

> 当block拷贝到堆上的时候，forwarding指针指向堆上的 __Block_byref_intValue_0 实例，
>
> **确保栈上的自动变量val出栈以后，通过forwarding能找到推上的val成员变量**



![](http://ohbzayk4i.bkt.clouddn.com/17-1-19/27092407-file_1484768361562_157da.jpg)

#### block的内存管理

![](http://blogofzuoyebuluo.qiniudn.com/image_note57603_2.png)

block的常见类型有3种：

- _NSConcreteGlobalBlock（全局） // 存储在全局变量区
- _NSConcreteStackBlock（栈）
- _NSConcreteMallocBlock（堆）

##### _NSConcreteGlobalBlock

> 1、当 block 字面量写在全局作用域时，即为 `global block`； 
> 2、当 block 字面量不获取任何外部变量时，即为 `global block`；
>
> 除了上述描述的两种情况，其他形式创建的 block 均为 `stack block`。

```c
// 下面 block 虽然定义在 for 循环内，但符合第二种情况，所以也是 global block
typedef int (^blk_t)(int);
for (int rate = 0; rate < 10; ++rate) 
{
    blk_t blk = ^(int count){return rate * count;}; 
}
```



##### _NSConcreteStackBlock && _NSConcreteMallocBlock 

由于_NSConcreteStackBlock所属的变量域一旦结束，那么该Block就会被销毁。在ARC环境下，编译器会自动的判断，把Block自动的从栈copy到堆。

1. 手动调用copy
2. block是方法返回值
3. Block被强引用，即Block被赋值给__strong类型
4. 调用系统API入参中含有usingBlcok的方法

但是**当Block为函数参数**的时候，就需要我们手动的copy一份到堆上了。例子如下

```c
typedef int (^Block)(void);
id getBlockArray()
{
    int val = 10;
    NSLog(@"%@", ^{NSLog(@"blklog:%d", val);});
    return [[NSArray alloc] initWithObjects:
            ^{NSLog(@"blk0:%d", val) ;} ,  // block 在栈上生成，没有被复制到堆上
            ^{NSLog(@"blk1:%d", val), nil];
}
int main(int argc, char * argv[]) {
    id arr = getBlockArray();
    Block block = [arr objectAtIndex:0];
    block(); // BAD_ACCESS 错误，因为栈上的block已经被销毁了
    return 0;
}
```

> **在不确定block是否被copy 到heap上的时候一律用copy**



  

#### block 在copy中的 __block自动变量和对象

#####  block copy到heap 时候自动变量的变化

![](http://ohbzayk4i.bkt.clouddn.com/17-1-18/69400135-file_1484733396740_a5c6.png)

> 相应的 __block也拷贝到堆上
>
> 

##### block copy到heap 时候对象的变化

```c
typedef void (^blk_t)(id obj);
blk_t blk;
- (void)viewDidLoad
{
    [self captureObject];
    blk([[NSObject alloc] init]);
    blk([[NSObject alloc] init]);
    blk([[NSObject alloc] init]);
}
- (void)captureObject
{
    id array = [[NSMutableArray alloc] init];
    blk = [^(id obj) {
             [array addObject:obj];
             NSLog(@"array count = %ld", [array count]);
          } copy];
}
```

```c
/* a struct for the Block and some functions */
struct __main_block_impl_0
{
    struct __block_impl impl;
    struct __main_block_desc_0 *Desc;
    id __strong array;
    __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, id __strong _array, int flags=0) : array(_array)
    {
        impl.isa = &_NSConcreteStackBlock; 
        impl.Flags = flags;
        impl.FuncPtr = fp;
        Desc = desc;
    }
};
static void __main_block_func_0(struct __main_block_impl_0 *__cself, id obj)
{
    id __strong array = __cself->array;
    [array addObject:obj];
    NSLog(@"array count = %ld", [array count]);
}
static void __main_block_copy_0(struct __main_block_impl_0 *dst, __main_block_impl_0 *src)
{
    _Block_object_assign(&dst->array, src->array, BLOCK_FIELD_IS_OBJECT);
}
static void __main_block_dispose_0(struct __main_block_impl_0 *src)
{
    _Block_object_dispose(src->array, BLOCK_FIELD_IS_OBJECT);
}
struct static struct __main_block_desc_0
{
    unsigned long reserved;
    unsigned long Block_size;
    void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
    void (*dispose)(struct __main_block_impl_0*);
} __main_block_desc_0_DATA = {  0,
                                sizeof(struct __main_block_impl_0),
                                __main_block_copy_0,
                                __main_block_dispose_0
                             };
/* Block literal and executing the Block */
blk_t blk;
{
    id __strong array = [[NSMutableArray alloc] init];
    blk = &__main_block_impl_0(__main_block_func_0, 
                               &__main_block_desc_0_DATA, 
                               array, 
                               0x22000000);
    blk = [blk copy];
}
(*blk->impl.FuncPtr)(blk, [[NSObject alloc] init]);
(*blk->impl.FuncPtr)(blk, [[NSObject alloc] init]);
(*blk->impl.FuncPtr)(blk, [[NSObject alloc] init]); 
```

> 说明: block捕获对象时候，内部会生成相应的对象的引用指针变量id _strong array;
>
> 当block被从栈上拷贝到堆上的时候即调用__main_block_copy_0 时候，strong类型的变量借助_Block_object_assign(相当于retain)持有对象，**这也是循环引用产生的根据，即block copy到堆上的时候，默认对他内部使用的对象进行强引用**,当block被销毁的时候，调用_Block_object_dispose(相当于release)对对象

> **问题:当block捕获外部对象的时候，理论上内部生成指向对象的指针，可以直接访问对象，意味着也可以修改对象，例如前面的设置 array = nil，但现实中却办不到，为什么呢？**



#### block 的循环引用

一个对象强用用了block,block又强引用了该对象，就会产生循环引用

> 由于 `self` 是 `__strong` 修饰，在 ARC 下，当编译器自动将代码中的 block 从栈拷贝到堆时，block 会强引用和持有`self`，而 `self` 恰好也强引用和持有了 block，就造成了传说中的循环引用。

```
@property(nonatomic, copy) completionBlock completionBlock;

//========================================
self.completionBlock = ^ {	
        if (self.success) {
            self.success(self.responseData);
        }
    }
};
```

![](http://blogofzuoyebuluo.qiniudn.com/image_note58470_2.png)

用__weak修饰self打断循环引用

```
@property(nonatomic, , copy) completionBlock completionBlock;

//========================================
__weak typeof(self) weakSelf = self;
self.completionBlock = ^ {
    if (weakSelf.success) {
        weakSelf.success(weakSelf.responseData);
    }
```



[学习Javascript闭包（-Closure）](http://www.ruanyifeng.com/blog/2009/08/learning_javascript_closures.html)

[block没那么难（一）：block的实现](https://www.zybuluo.com/MicroCai/note/51116)

[http://chun.tips/blog/2014/11/13/hei-mu-bei-hou-de-blockxiu-shi-fu/](黑幕背后的__block修饰符)



