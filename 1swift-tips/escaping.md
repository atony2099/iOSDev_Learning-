---
title: escaping
date: 2016-05-01 00:22:12
tags:
---

#### 1.Escaping Closure

>  一个闭包作为一个参数传递给一个函数，并且在函数return之后才被唤起执行



![](http://ohbzayk4i.bkt.clouddn.com/16-12-24/50262357-file_1482564200621_e595.png)



什么情况下会引起逃逸？

> 1. Asynchronous execution: If you execute the closure asynchronously on a dispatch queue, the queue will hold onto the closure for you. You have no idea *when* the closure will be executed and there’s no guarantee it will complete before the function returns.
> 2. Storage: Storing the closure to a global variable, property, or any other bit of storage that lives on past the function call means the closure has also escaped

swift3闭包默认是非逃逸，逃逸闭包需要加上@escaping标记

默认非逃逸的好处:

1. 最明显的好处就是编译器优化你的代码的性能和能力。如果编译器知道这个闭包是不可逃逸的，它可以关注内存管理的关键细节。
2. 可以在不可逃逸闭包里放心的使用self关键字，因为这个闭包总是在函数return之前执行，你不需要去使用一个弱引用去引用self.
