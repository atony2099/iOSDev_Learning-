---
title: Anyobject
date: 2016-09-01 00:22:12
tags:
---

#### Any && AnyObject来源

#### 基础

Any:可以代表 struct、class、func 等等几乎所有类型

AnyObject : class类型

> 建议：这是妥协的产物，最好还是指定明确的烈性

> `AnyObject`是`Any`的子集

####  swift 3之前的

> 那为什么之前我们在 Swift 2  里可以用 [AnyObject] 声明数组，并且在里面放 Int、String 等 struct 类型呢？这是因为 Swift 2 中，会针对这些 Int、String 等 struct 进行一个 Implicit Bridging Conversions，在 Array 里插入他们时，编译器会自动将其 bridge 到 Objective-C 的 NSNumber、NSString 等类型，这就是为什么我们声明的 [AnyObject] 里可以放 struct 的原因。





[适配 Swift 3 的一点小经验和坑](https://zhuanlan.zhihu.com/p/22584349)

