---
title: Understanding the Objective-C Runtime
date: 2016-01-08 19:30:25
tags:

---



#### runtime基础概念

##### 动态语言VS静态语言

- c语言: 代码执行的逻辑在在编译的时候会决定好，编译完成之后直接顺序执行，无任何二义性

- oc:它会尽可能地把代执行的决策从编译和链接的时候，推迟到运行时。(关于编译和连接，参考这篇文章[编译器的工作过程](http://www.ruanyifeng.com/blog/2014/11/compiler.html)

  > Objective-C最大的特色是承自[Smalltalk](https://zh.wikipedia.org/wiki/Smalltalk)的消息传递模型（message passing），此机制与今日[C++](https://zh.wikipedia.org/wiki/C%2B%2B)式之主流风格差异甚大。Objective-C里，与其说对象互相**调用方法**，不如说对象之间**互相传递消息**更为精确。
  >
  > 定义：runtime是用c和汇编写的一个动态库，oc面向对象的能力是建立在这个库上的，他主要做了两件事
  >
  > - 封装: 封装(对象，类封装成结构体
  > - 消息派发

##### 对象结构体

```c
typedef struct objc_class *Class;
struct objc_object {
    Class isa  OBJC_ISA_AVAILABILITY;  //对象内部的指针指向类对象结构体
};
typedef struct objc_object *id;

struct objc_class {  // 类对象结构体 

    Class isa  OBJC_ISA_AVAILABILITY; // 类对象isa指针指向它的meta class

#if !__OBJC2__

    Class super_class                       OBJC2_UNAVAILABLE;  // 父类

    const char *name                        OBJC2_UNAVAILABLE;  // 类名

    long version                            OBJC2_UNAVAILABLE;  // 类的版本信息，默认为0

    long info                               OBJC2_UNAVAILABLE;  // 类信息，供运行期使用的一些位标识

    long instance_size                      OBJC2_UNAVAILABLE;  // 该类的实例变量大小

    struct objc_ivar_list *ivars            OBJC2_UNAVAILABLE;  // 该类的成员变量链表

    struct objc_method_list *methodLists   OBJC2_UNAVAILABLE;  // 方法定义的链表

    struct objc_cache *cache                OBJC2_UNAVAILABLE;  // 方法缓存的链表

    struct objc_protocol_list *protocols    OBJC2_UNAVAILABLE;  // 协议链表

#endif

} OBJC2_UNAVAILABLE;
```



![](http://ohbzayk4i.bkt.clouddn.com/17-1-13/70107463-file_1484309681712_8217.jpg)

类对象结构体存储着实例实例对象的方法列表，成员变量信息

#### 消息转发

##### 编译器转换

[receiver message];

会被编译器转换为

objc_msgSend(receiver, @selector(message));



>  id objc_msgSend(id self, SEL _cmd, ...)
>
>  - SEL表示选择器，是一个结构体，可以理解为一个字符串，它维护着一张SEL,将相同字符串的方法名映射到唯一一个SEL。
>
>   简单说SEL就是一个方法的id
>
>  typedef id (*IMP)(id, SEL, ...);
>
>  - IMP表示方法地址



objc_class中 method list保存了一组SEL<->IMP的映射。

![](http://img.blog.csdn.net/20130718230259187?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQveWl5YWFpeHVleGk=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

##### obj_msgSend 执行

```objective-c
id objc_msgSend(id self, SEL op, ...) {
    if (!self) return nil;
	IMP imp = class_getMethodImplementation(self->isa, SEL op);
	imp(self, op, ...); //调用这个函数，伪代码...
}

//查找IMP
IMP class_getMethodImplementation(Class cls, SEL sel) {

    if (!cls || !sel) return nil;
    IMP imp = lookUpImpOrNil(cls, sel);
   if (!imp) return _objc_msgForward; //这个是用于消息转发的
    return imp;
}

IMP lookUpImpOrNil(Class cls, SEL sel) {

    if (!cls->initialize()) {
        _class_initialize(cls);
    }


    Class curClass = cls;

    IMP imp = nil;

    do { //先查缓存,缓存没有时重建,仍旧没有则向父类查询

        if (!curClass) break;

        if (!curClass->cache) fill_cache(cls, curClass);

        imp = cache_getImp(curClass, sel);

        if (imp) break;

    } while (curClass = curClass->superclass);
    return imp;
}
```



我们可以梳理出相关方法的执行过程: 

1. 检查receiver是否为nil，如果为nil，直接return(这也是为什么我们向一个nil发送消息不会crash)

2. 根据receiver 内部的iSA指针找到它所指向的类对象，然后再根据SEL查询IMP 

   - 先查询cache 方法链表
   - 再从methodList查找
   - 还没找到，就沿着继承体系向上查找，一直找到NSObject
   - 如果一直查找到根类仍旧没有实现。调用_objc_msgForward函数，_objc_msgForward作用是在程序抛出*unrecognized selector sent to* 之前调用消息转发的方法，让你有机会拯救程序

   ​

   增加 方法的实现或者转发给其他对象

   ![](http://ohbzayk4i.bkt.clouddn.com/17-1-14/68070652-file_1484404278995_151e3.png)

   ​

   - `+resolveInstanceMethod:` 或者 `+resolveClassMethod:`，让你有机会提供一个函数实现。如果你添加了函数并返回 YES

   ![](http://upload-images.jianshu.io/upload_images/203794-964ecb6df5e56591.png?imageView2/2/w/1240/q/100)

   - fast forwarding: 调用这个方法，给你把这个消息转发给其他对象的机会,如果获取到，直接转发给它。如果返回nil，继续下面操作

   ![](http://upload-images.jianshu.io/upload_images/203794-481320569772a444.png?imageView2/2/w/1240/q/100)

   - Normal forwarding :这一步是 Runtime 最后一次给你挽救的机会。运行时系统会在这一步给消息接收者最后一次机会将消息转发给其它对象。对象会创建一个表示消息的NSInvocation对象，把与尚未处理的消息 有关的全部细节都封装在anInvocation中，包括selector，目标(target)和参数。我们可以在forwardInvocation 方法中选择将消息转发给其它对象。

   ![](http://upload-images.jianshu.io/upload_images/203794-7e5f61f4588a208e.png?imageView2/2/w/1240/q/100)

   ​




#### method swizzle

##### 是什么: 改变method list SEL 所指向的IMP指针

- AOP编程 ：
  - 统计打点
  - 安全检查(字典，数组)

#### 隐藏参数

当`objc_msgSend`找到方法对应的实现时，它将直接调用该方法实现，并将消息中所有的参数都传递给方法实现,同时,它还将传递两个隐藏的参数:

- 接收消息的对象（也就是`self`指向的内容）
- 方法选择器（`_cmd`指向的内容）

之所以说它们是隐藏的是因为在源代码方法的定义中并没有声明这两个参数。它们是在代码被编译时被插入实现中的。尽管这些参数没有被明确声明，在源代码中我们仍然可以引用它们。

`[super class]`

最终会转换为

`objc_msgSend(objc_super->receiver, @selector(class))`去调用，此时已经和`[self class]`调用相同了

##### 成员变量

Ivar 在objc中被定义为：

```c
typedef struct objc_ivar *Ivar;
struct objc_ivar {
    char *ivar_name                                       OBJC2_UNAVAILABLE;
    char *ivar_type                                       OBJC2_UNAVAILABLE;
    int ivar_offset// 地址编译量                                       OBJC2_UNAVAILABLE;
#ifdef __LP64__
    int space                                             OBJC2_UNAVAILABLE;
#endif
}                                                            OBJC2_UNAVAILABLE;


```



在编译我们的类时，编译器生成了一个 ivar布局，显示了在类中从哪可以访问我们的 ivars 

![](http://ohbzayk4i.bkt.clouddn.com/17-1-14/94404242-file_1484402886263_12112.png)



> 对象的内存布局是 = isa指针 + 父类成员变量+子类成员变量

我们对 ivar 的访问就可以通过 对象地址 ＋ ivar偏移字节的方法

```c
@interface Student : NSObject
{
    @private
    int age;
}
@end
@implementation Student
- (NSString *)description
{
    NSLog(@"current pointer = %p", self);
    NSLog(@"age pointer = %p", &age);
    return [NSString stringWithFormat:@"age = %d", age];
}
@end
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Student *student = [[Student alloc] init];
        Ivar age_ivar = class_getInstanceVariable(object_getClass(student), "age");
        int *age_pointer = (int *)((__bridge void *)(student) + ivar_getOffset(age_ivar));
        NSLog(@"age ivar offset = %td", ivar_getOffset(age_ivar));
        *age_pointer = 10;
        NSLog(@"%@", student);
    }
    return 0;
}
```

输出结果

```
2014-11-08 18:24:38.892 Test[4143:466864] age ivar offset = 8
2014-11-08 18:24:38.893 Test[4143:466864] current pointer = 0x1001002d0
2014-11-08 18:24:38.893 Test[4143:466864] age pointer = 0x1001002d8
2014-11-08 18:24:38.894 Test[4143:466864] age = 10
```



相关参考文档: 

[[Objective-C内存布局](http://www.cnblogs.com/csutanyu/archive/2011/12/12/Objective-C_memory_layout.html)](http://www.cnblogs.com/csutanyu/archive/2011/12/12/Objective-C_memory_layout.html)

[刨根问底Objective－C Runtime（3）－ 消息 和 Category](http://chun.tips/blog/2014/11/06/bao-gen-wen-di-objective%5Bnil%5Dc-runtime(3)%5Bnil%5D-xiao-xi-he-category/)

[刨根问底Objective－C Runtime](http://www.cocoachina.com/ios/20141224/10740.html)

[Objective-C 中的消息与消息转发](http://blog.ibireme.com/2013/11/26/objective-c-messaging/)

[轻松学习之 Objective-C消息转发](http://www.cocoachina.com/ios/20150604/12013.html)

[Objective-C Runtime](http://tech.glowing.com/cn/objective-c-runtime/)

[Objective-C Runtime 运行时之一：类与对象](http://southpeak.github.io/blog/2014/10/25/objective-c-runtime-yun-xing-shi-zhi-lei-yu-dui-xiang/)


