---
title: init方法
date: 2016-05-01 00:22:12
tags:
---

[构造过程](http://wiki.jikexueyuan.com/project/swift/chapter2/14_Initialization.html)

- init 

构造过程: 使用类，结构体，的实例之前的准备过程，

1. 设置非optional实例变量还没赋值的的初始值。
2. 其他一些初始化工作



规则: 

- 指定构造器必须总是*向上*代理
- 便利构造器必须总是*横向*代理指定构造器调用父亲指定构造器



#### 两段式构造过程

1. 每个存储属性指定一个初始值

2. 进一步定制存储属性

   > vs object-c: object-c帮我们指定了初始值(nil 或者 0)



#### 构造函数的重载,重写

重载: overload: 参数列表: 不一样，返回列表： 无所谓

> ```
> 一旦重载构造函数  默认的构造函数就不能访问
> ```

重写 override :参数列表和返回类型一致



#### 构造器的继承: 

子类默认情况下不会继承父类的构造器

 1 . 如果子类没有定义任何指定构造器，它将自动继承父类的指定构造器

2.  如果他实现了弗雷所有指定构造实现，他也就继承所有便利构造器





```
import UIKit

class wheel: UIControl {

}
```

But this code doesn't:

```
class wheel: UIControl {
override init(frame: CGRect) {
    super.init(frame: frame)
}
```

It shows error "*required initializer init must be provided in subclass of UIControl*" when I override init(frame: CGRect) but not init(coder aDecoder: NSCoder)

Look. According to [Apple documentations](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Initialization.html) Swift subclasses do not inherit their superclass initializers by default. They are inherited only in certain circumstances, one of which is: If your subclass doesn’t define any designated initializers, it automatically inherits all of its superclass designated initializers. So if you're not implementing `init(frame: CGRect)` all super initializers are inherited.

Also UIView adopts NSCoding protocol, which requires an `init(coder:)` initializer. So if you're implementing `init(frame: CGRect)`, your class is no longer inheriting super initializers. So you must implement that one too:

```swift
required init?(coder decoder: NSCoder) {
    super.init?(coder: decoder)
}
```

> 批阅: 你自己实现了一个指定构造器，那你就不继承了他的构造器了。

#### 可失败的构造器

如果一个类、结构体或枚举类型的对象，在构造过程中有可能失败，则为其定义一个可失败构造器。这里所指的“失败”是指，如给构造器传入无效的参数值，或缺少某种所需的外部资源，又或是不满足某种必要的条件等。

```swift
struct Animal {
    let species: String
    init?(species: String) {
        if species.isEmpty { return nil }
        self.species = species
    }
}
```

