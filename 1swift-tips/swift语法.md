---
title: swift语法
date: 2017-11-15 11:07:32
tags:
---

1. 参数的两种传递方式

   - 值传递: 传递的是参数的副本
   - 引用传递： 把参数的内存地址传过去: 在Swift众多数据类型中，只有class是**引用**类型， 

   ```swift
   var value = 50
   print(value)  // 此时value值为50

   func increment(inout value: Int, length: Int = 10) {
       value += length
   }

   increment(&value)
   print(value)  // 此时value值为60，成功改变了函数外部变量value的值
   ```

#### objc

> @objc is prefixed to classes to allow them to be used in ObjC. If you're dealing purely in Swift, it is unnecessary.
>
> Also, if your class inherits from an ObjC class, the prefix is unnecessary.



注意这个步骤只需要对那些不是继承自 `NSObject` 的类型进行，如果你用 Swift 写的 class 是继承自 `NSObject` 的话，Swift 会默认自动为所有的非 private 的类和成员加上 `@objc`。这就是说，对一个 `NSObject` 的子类，你只需要导入相应的头文件就可以在 Objective-C 里使用这个类了。



#### 内存管理

swift 与OC 一样，都是引用计数器管理内存，所有OC中该用weak的地方，swift照旧要用。



####  ArgumentName  &&  ArgumentLabel

> Each function parameter has both an *argument label* and a *parameter name*. The argument label is used when calling the function; each argument is written in the function call with its argument label before it. The parameter name is used in the implementation of the function. By default, parameters use their parameter name as their argument labe
>
> - 函数参数默认有label(对外) + name(对内)
>
> The use of argument labels can allow a function to be called in an expressive, sentence-like manner, while still providing a function body that is readable and clear in intent
>
> ```
> func greet(person: String, from hometown: String) -> String {
>     return "Hello \(person)!  Glad you could visit from \(hometown)."
> }
> print(greet(person: "Bill", from: "Cupertino"))
> ```
>
> - 单独定义label会使你函数可读性更强
>
> If you don’t want an argument label for a parameter, write an underscore (`_`) instead of an explicit argument label for that parameter.
>
> ```swift
> func someFunction(_ firstParameterName: Int, secondParameterName: Int) {
>     // In the function body, firstParameterName and secondParameterName
>     // refer to the argument values for the first and second parameters.
> }
> someFunction(1, secondParameterName: 2)
> ```
>
> If a parameter has an argument label, the argument *must* be labeled when you call the function.
>
> - 可以指定label 省略_ 这样调用的时候就不用谢参数



#### weak - unownd

> 都不会增加引用计数
>
> unownd 是非可选类型，是有值的，也就是他指向的对象不会是nil， 一般比较少用





#### static - class

> 类型返回作用域， class 专门用于class类型，但是不能修饰存储属性。 static适用所有场景



# optional

```swift
var word2 :String
var word1 :String?
var word3: String!
```

> 1. String represents a String that's guaranteed to be present. There is no way this value can be nil, thus it's safe to use directly.
> 2. String? represents a Optional<String>, which can be null. You can't use it directly, you must first unwrap it (using a guard, if let, or ! (force unwrap operator)). As long as you don't force unwrap it with !, this too is safe.
> 3. String! also represents an Optional<String>, which can be nil. However, this optional is always implicitly unwrapped. It's like having a String? and ALWAYS force unwrapping it with !. These are dangerous, as any use of them will crash your program (unless you check for nil manually).
