---
title: autorelesePool
date: 2015-9-12 20:18:02
tags:
---

#### autoreleasePool的实现原理

1. autoreleasePool是由若干个AutoreleasePoolPage以双向链表组成， 每一个线程的 autoreleasepool 按堆栈的方式存储对象的指针，id *next指针作为游标指向栈顶最新add进来的autorelease对象的下一个位置
   - 一个AutoreleasePoolPage的空间被占满时，会新建一个AutoreleasePoolPage对象，连接链表，后来的autorelease对象在新的page加入
   - 每当进行一次objc_autoreleasePoolPush调用时，runtime向当前的AutoreleasePoolPage中add进一个`哨兵对象，值为0（也就是个nil）,并从哨兵对象对象对象位置开始存储指针

![](http://ohbzayk4i.bkt.clouddn.com/17-1-17/66532911-file_1484604072733_11269.jpg)

2. objc_autoreleasePoolPush的返回值正是这个哨兵对象的地址，被objc_autoreleasePoolPop(哨兵对象)作为入参，于是：
   - 根据传入的哨兵对象地址找到哨兵对象所处的page
   - 在当前page中，将晚于哨兵对象插入的所有autorelease对象都发送一次- release消息，并向回移动next指针到正确位置
     ![](http://ohbzayk4i.bkt.clouddn.com/17-1-17/52002764-file_1484604072858_134b7.jpg)



#### autoreleased 对象的释放时机

![](http://ohbzayk4i.bkt.clouddn.com/17-1-17/32208599-file_1484656781760_283c.gif)

 在每一个runloop周期内，runloop 都会创建一个autoreleasepool，在runloop即将休眠 drain 这个pool

autoreleased对象此时被释放

#### autoreleasepool 使用场景

1. If you write a loop that creates many temporary objects.

   You may use an autorelease pool block inside the loop to dispose of those objects before the next iteration. Using an autorelease pool block in the loop helps to reduce the maximum memory footprint of the application

   >个人理解: 如果在短时间创建了大量autoreleased对象，内存会迅速增加，但是autoreleased对象要等待本次runloop周期结束后才释放，这时候可以手动创建autoreleasepool池即时释放

   ​

2. If you spawn a secondary thread.

   You must create your own autorelease pool block as soon as the thread begins executing; otherwise, your application will leak objects.

   > 个人理解: 在实际开发中，我们最长使用时GCD和NSOperation,在两个框架下，会自动帮我们构建autoreleasepool，所以即使没有显示调用autoreleasepool，也不一定会造成很大的内存泄露问题,
   >

   参考stack overflow：

   [Do you need to create an NSAutoreleasePool within a block in GCD?](http://stackoverflow.com/questions/4141123/do-you-need-to-create-an-nsautoreleasepool-within-a-block-in-gcd)

   > If your block creates more than a few Objective-C objects, you might want to enclose parts of your block’s code in an @autorelease block to handle the memory management for those objects. Although GCD dispatch queues have their own autorelease pools, they make no guarantees as to when those pools are drained. If your application is memory constrained, creating your own autorelease pool allows you to free up the memory for autoreleased objects at more regular intervals.

   ​

[Using Autorelease Pool Blocks](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/MemoryMgmt/Articles/mmAutoreleasePools.html)

[黑幕背后的Autorelease](http://blog.sunnyxx.com/2014/10/15/behind-autorelease/)

[Objective-C Autorelease Pool 的实现原理](http://blog.leichunfeng.com/blog/2015/05/31/objective-c-autorelease-pool-implementation-principle/)



