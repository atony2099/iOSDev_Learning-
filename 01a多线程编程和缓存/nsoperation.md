---
title: NSOperation
date: 2016-2-03 15:13:11
tags:
---





#### cancel

A Boolean value indicating whether the operation has been cancelled

The default value of this property is [false](apple-reference-documentation://hsgzyHrlAT). Calling the [cancel()](apple-reference-documentation://hsOwwt40xm) method of this object sets the value of this property to [true](apple-reference-documentation://hssD4Kc5Ce). Once canceled, an operation must move to the finished state.

Canceling an operation does not actively stop the receiver’s code from executing. An operation object is responsible for calling this method periodically and stopping itself if the method returns [true](apple-reference-documentation://hssD4Kc5Ce).

You should always check the value of this property before doing any work towards accomplishing the operation’s task, which typically means checking it at the beginning of your custom `main()` method. It is possible for an operation to be cancelled before it begins executing or at any time while it is executing. Therefore, checking the value at the beginning of your `main()`method (and periodically throughout that method) lets you exit as quickly as possible when an operation is cancelled.


> 取消operation 是你应该负责的事情

几个考虑加入cancel的地方:
1. 在执行任何实际的工作之前
2. 在循环的每次迭代过程中，如果每个迭代相对较长可能需要调用
