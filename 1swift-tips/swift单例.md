---
title: Swift单例
date: 2016-10-12 19:48:20
tags: 
---

#### 全局变量 && 类的变量

- 针对某个类，全局变量一般是声明在类的作用范围外的变量
- 类的变量(类型)：用static修饰，定义在 类的最外层括号

> 在 C 或 Objective-C 中，与某个类型关联的静态常量和静态变量，是作为全局（*global*）静态变量定义的。但是在 Swift 中，类型属性是作为类型定义的一部分写在类型最外层的花括号内，因此它的作用范围也就在类型支持的范围内。

使用关键字 `static` 来定义类型属性。在为类定义计算型类型属性时，可以改用关键字 `class` 来支持子类对父类的实现进行重写。下面的例子演示了存储型和计算型类型属性的语法：

```
struct SomeStructure {
    static var storedTypeProperty = "Some value."
    static var computedTypeProperty: Int {
        return 1
    }
}
enum SomeEnumeration {
    static var storedTypeProperty = "Some value."
    static var computedTypeProperty: Int {
        return 6
    }
}
class SomeClass {
    static var storedTypeProperty = "Some value."
    static var computedTypeProperty: Int {
        return 27
    }
    class var overrideableComputedTypeProperty: Int {
        return 107
    }
}
```

- 全局变量和类的变量默认都是懒加载，swift的懒加载相当于OC调用dispatch_once

> （“The lazy initializer for a global variable (also for static members of structs and enums) is run the first time that global is accessed, and is launched as `dispatch_once` to make sure that the initialization is atomic. This enables a cool way to use `dispatch_once` in your code: just declare a global variable with an initializer and mark it private.”）



#### 实现单例

由此我们可以知晓实现单例的两种方式

```swift
// 使用全局变量
private let instance = Model()
class Model: NSObject {
    class func shared() -> Model {
        return instance
    }
}

// 使用类的变量
class Model: NSObject { 
    static let shared = Model()
}
```





