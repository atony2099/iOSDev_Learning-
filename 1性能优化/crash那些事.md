---
title: crash那些事
date: 2016-04-18 15:39:04
tags:
---

#### iTunes  connect 

> 分析崩溃的总体

![](http://upload-images.jianshu.io/upload_images/1182487-9e500a7176d98758.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#####  xcode crashs

xcode： window->organizer

> 定位到相关代码

![](http://upload-images.jianshu.io/upload_images/1182487-ab0a3570cc610999.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)





[http://www.jianshu.com/p/799dcb0cb5ba](http://www.jianshu.com/p/799dcb0cb5ba)



#### receivememory warning 



在 iOS6 中，由于 viewDidUnload 事件在 iOS6 下任何情况都不会被触发，所以苹果在文档中建议，应该将回收内存的相关操作移到另一个回调函数：didReceiveMemoryWarning 中。但是如果你仅仅是把以前写到 viewDidUnload 函数中的代码移动到 didReceiveMemoryWarning 函数中，那么你就错了。以下是一个 错误的示例代码 ：

```objective-c
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if([self isViewLoaded] && ![[self view] window]) {
        [self setView:nil];
    }
}
```

> 在 iOS6 时，当系统发出 MemoryWarning 时，系统会自动回收 bitmap 类。但是不回收 UIView 和 CALayer 类。这样即回收了大部分内存，又能在需要 bitmap 类时，通过调用 UIView 的 drawRect: 方法重建。

**所以，简单来说，对于 iOS6，你不需要做任何以前 viewDidUnload 的事情，更不需要把以前 viewDidUnload 的代码移动到 didReceiveMemoryWarning 方法中。**



[再见，viewDidUnload方法](http://blog.devtang.com/2013/05/18/goodbye-viewdidunload/)](http://blog.devtang.com/2013/05/18/goodbye-viewdidunload/)

[iOS中常见 Crash 及解决方案](http://ios.jobbole.com/88851/)

[http://www.swifthumb.com/thread-11284-1-1.html](http://www.swifthumb.com/thread-11284-1-1.html)

