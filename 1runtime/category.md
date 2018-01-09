---
title: category
date: 2016-04-09 20:46:08
tags:category
---

#### category是什么?

苹果文档如是说: 

> You use categories to define additional methods of an existing class—even one whose source code is unavailable to you—without subclassin

特点: 轻量级的扩展方法的方式，用category拓展方法明显的好处是可以用来拆分功能,让一个大型的类让一个大型的类分治管理。

```
// Sark.h
@interface tfenglin : NSObject
@end

@interface Sark (play)  // 学习的分类
- (void)play;
@end

@interface Sark (study) // 工作的分类 
- (void)study;
@end
```

category使用要注意的原则:category 的实现可以依赖主类，但主类一定不依赖 category，也就是说移除任何一个 Category 的代码不会对主类产生任何影响。

>  所以 Category 一定是简单插拔的，就像买个外接键盘来扩展在 MacBook 上的写码能力，但当拔了键盘，MacBook 的运行不会受到任何影响。--sunnyxx



#### category 和extension

category在语法上一般被成视为匿名的extension，但他们在实现机制上差别很大。

> Class Extension 编译器决议，它就是类的一部分，编译的时候会将Extension的属性和方法合并进入主类，
>
> Category 是运行期决议   在程序启动 Runtime Loading 时才会将方法、属性合入主类。
>
> Category 无法添加成员变量，因为在运行期，对象的内存布局已经确定好了

##### extension使用场景

>  this(extension)  is a way to declare "pseudo-private" methods (pseudo-private in that they're not really private, just not externally exposed). --stackoverflow 
>
> extension可以理解为声明"私有方法(属性)"的一种方式，



#### runtime对category处理 

我们知道OC中的类和对象都可以用结构体来表示，category也不例外:

```c
typedef struct category_t {
    const char *name; // 类名
    classref_t cls; // 要关联的类对象
    struct method_list_t *instanceMethods; // 给类添加的实例方法的列表
    struct method_list_t *classMethods; //给类添加的类方法的列表
    struct protocol_list_t *protocols; // 给类添加协议列表
    struct property_list_t *instanceProperties; // 给类添加实例属性
} category_t;
```

从category的数据结构可以看出没有实例变量这一项，这再一次佐证了category                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    无法添加实例变量的特性。

> 为何runtime期间可以动态的添加方法？
>
> 对象的方法列表是由类对象objc_class 管理的， 不管如何增删类方法，都不影响对象的内存布局



runtime处理category时候，会调用两拨方法， 一组是实例对象相关的调用`addUnattachedCategoryForClass`，一拨是类对象相关的调用`addUnattachedCategoryForClass`，然后会调到`attachCategoryMethods`方法，这个方法把一个类所有的category_list的所有方法取出来组成一个`method_list_t **`

attachCategoryMethods方法如下所示: 

```
static void
attachCategoryMethods(class_t *cls, category_list *cats,
                      BOOL *inoutVtablesAffected)
{
    if (!cats) return;
    if (PrintReplacedMethods) printReplacements(cls, cats);

    BOOL isMeta = isMetaClass(cls);
    method_list_t **mlists = (method_list_t **)
        _malloc_internal(cats->count * sizeof(*mlists));

    // Count backwards through cats to get newest categories first
    int mcount = 0;
    int i = cats->count;
    BOOL fromBundle = NO;
    while (i--) {
        method_list_t *mlist = cat_method_list(cats->list[i].cat, isMeta);
        if (mlist) {
            mlists[mcount++] = mlist;
            fromBundle |= cats->list[i].fromBundle;
        }
    }

    attachMethodLists(cls, mlists, mcount, NO, fromBundle, inoutVtablesAffected);

    _free_internal(mlists);

}
```

这边有两个核心点: 

1. category的方法没有“完全替换掉”原来类已经有的方法，也就是说如果category和原来类都有methodA，

   在运行期，这两个方法会合并成一个新的方法列表

2. category的方法被放到了新方法列表的前面，而原来类的方法被放到了新方法列表的后面，这也就是我们平常所说的category的方法会“覆盖”掉原来类的同名方法，这是因为运行时在查找方法的时候是顺着方法列表的顺序查找的，它只要一找到对应名字的方法, ，就会罢休，殊不知后面可能还有一样名字的方法

#### associated  object 

虽然category不能添加成员变量，但通过associated  object却可以弥补这一不足，顾名思义，他是一个关联对象，把一个key-object和已知的对象关联起来。

**相关函数**

```objective-c
void objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy); // 类似set方法
id objc_getAssociatedObject(id object, const void *key); // 类似get方法
void objc_removeAssociatedObjects(id object);
```

`objc_removeAssociatedObjects` 函数我们一般是用不上的，因为这个函数会移除一个对象的所有关联对象，将该对象恢复成“原始”状态
上文函数key指针参数，推荐使用@selector(),它能确保key值是唯一的常量


**关联策略**

主要有五种关联策略

| 关联策略                              | 等价属性                                     | 说明              |
| --------------------------------- | ---------------------------------------- | --------------- |
| OBJC_ASSOCIATION_ASSIGN           | @property (assign) or @property (unsafe_unretained) | 弱引用关联对象         |
| OBJC_ASSOCIATION_RETAIN_NONATOMIC | @property (strong, nonatomic)            | 强引用关联对象，且为非原子操作 |
| OBJC_ASSOCIATION_COPY_NONATOMIC   | @property (copy, nonatomic)              | 复制关联对象，且为非原子操作  |
| OBJC_ASSOCIATION_RETAIN           | @property (strong, atomic)               | 强引用关联对象，且为原子操作  |
| OBJC_ASSOCIATION_COPY             | @property (copy, atomic)                 | 复制关联对象，且为原子操作   |

> 1. 关联对象与被关联对象本身的存储并没有直接的关系，它是存储在单独的哈希表中的；
> 2. 关联对象的五种关联策略与属性的限定符非常类似，在绝大多数情况下，我们都会使用`OBJC_ASSOCIATION_RETAIN_NONATOMIC` 的关联策略，这可以保证我们持有关联对象；



[[Associated Objects](http://nshipster.com/associated-objects/)](http://nshipster.com/associated-objects/)

[深入理解Objective-C：Category](http://tech.meituan.com/DiveIntoCategory.html)

[Objective-C对象模型及应用](http://blog.devtang.com/2013/10/15/objective-c-object-model/)

[Objective-C Associated Objects 的实现原理](http://blog.leichunfeng.com/blog/2015/06/26/objective-c-associated-objects-implementation-principle/)

[objc category的秘密](http://blog.sunnyxx.com/2014/03/05/objc_category_secret/)