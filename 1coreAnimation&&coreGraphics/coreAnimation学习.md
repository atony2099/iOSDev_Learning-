---
title: CoreAnimation学习
date: 2016-04-2 20:52:18
tags:
---

 **相关学习资料 **:


- 文档M
   [Core Animation编程指南2013中文](http://blog.csdn.net/mad2man/article/details/16928891)
  [Core Animation编程指南2011中文](http://www.cocoachina.com/bbs/read.php?tid=84461&fpage=3)
  [Core Animation编程指南英文]([Core Animation编程指南2011中文])
  [Core Animationg高级技巧](https://www.gitbook.com/book/zsisme/ios-/details)
- 相关博客
  [动画解 释](http://objccn.io/issue-12-1/)
  [谈谈iOS Animation](http://geeklu.com/2012/09/animation-in-ios/)  
  [View-Layer 协作](http://objccn.io/issue-12-4/)
  [你给我解析清楚，都有了CALayer了，为什么还要UIView](http://www.cocoachina.com/ios/20150828/13257.html)
  [UIView 和 CALayer的那点事](http://o0o0o0o.iteye.com/blog/1728599)


![UIKit](http://cdn.cocimg.com/cms/uploads/allimg/140515/4196_140515121200_1.png)


####CALayer
1. 什么是图层(CALayer)
   - 图层是一个模型对象(data object):
   > 图层管理位图周围状态信息
   > -> A layer merely manages the state information surrounding a bitmap.

   > layers manage information about the geometry, content, and visual attributes of their surfaces.


1.  how:  CALayer的渲染过程？
    ![](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/CoreAnimation_guide/Art/basics_layer_rendering_2x.png)
    1.a layer captures the content your app provides and caches it in a bitmap,
2.  When you subsequently change a property of the layer, all you are doing is changing the state information associated with the layer object
3.  When a change triggers an animation, Core Animation passes the layer’s bitmap and state information to the graphics hardware,

4.  coreAnimation和coreGraphics比较：
>  But drawing in this way is expensive because **it is done using the CPU on the main thread. **Core Animation avoids this expense by whenever possible by manipulating the cached bitmap in hardware to achieve the same or similar effects.



1. CALayer三层模型
   ![图片](https://zsisme.gitbooks.io/ios-/content/chapter7/7.4.jpeg)
   **Layer也和View一样存在着一个层级树状结构,称之为图层树(Layer Tree)**

**三个模型层对象**
-   Model Tree。在这个树中的对象是模型对象，模型对象负责存储所有动画的结束值。无论何时改变图层的属性值，你使用的始终是某一个模型对象。

-   Presentation Tree。呈现树中的对象包含所有运行中的动画的瞬时值。图层树对象包含的是动画的目标值，而呈现树中的对象代表显示在屏幕上动画的当前值。你不应该更改这个树中的对象。相反，你使用这些对象来读取当前动画的值，可能用于创建开始于这些值的新的动画。
    通过-presentationLayer方法来访问。这个呈现图层实际上是模型图层的复制，但是它的属性值代表了在任何指定时刻当前外观效果。换句话说，你可以通过呈现图层的值来获取当前屏幕上真正显示出来的值
    大多数情况下，你不需要直接访问呈现图层
     **如果想准确地知道在某一时刻图层显示在什么位置就会对正确摆放图层很有用了。**

-   Render Tree 在渲染树中的对象执行实际的动画，并且对Core Animation是不公开的。,渲染树是对呈现树的数据进行渲染,为了不阻塞主线程,渲染的过程是在单独的进程或线程中进行的,所以你会发现Animation的动画并不会阻塞主线程.

1. 图层的赋值方式
- 直接赋值一个UIImage对象给图层对象contents属性。（这个技术适用于图层内容从不或几乎不改变的情形。）
- 赋值一个代理给图层，由代理负责绘制图层内容。（该技术适用于图层内容可能偶尔改变，且内容可由外部对象提供，比如视图。）
- 定义一个CALayer的子类并覆盖类的绘图方法，有覆盖的方法返回图层的内容。（该技术适用于你需要创建自定义图层的子类，或者你想改变图层基本的绘图行为。）


---

>  图层并不知道当前设备的分辨率信息。**图层只是简单的存储一个指向位图的指针**，并用给定的有效像素以最佳的方式显示。如果你赋值一个图片给图层的contents属性，你必须给图层的contentsScale属性设置一个正确的值以告诉Core Animation关于图片的分辨率。默认的属性值为1.0，对于在标准分辨率的屏幕上显示图片是正确的。如果你的图片要在Retina屏幕上显示，该值需要设定为2.0。使用[[UIScreen mainScreen] scale]可获取正确的缩放率。

----

> 核心动画不提供在一个窗口(window)实际显示图层的手段，它们必须通过视图来
> 托管。当视图和图层一起的时候，视图为图层提供了底层的事件处理，而图层为视图
> 提供了显示的内容。
> **iOS 上面的视图系统直接建立在核心动画的图层上面。**

---

------

>  当你随后改变了一个图层的属性值，你做的所有工作只是改变了与图层对象相关联的状态信息。当你的更改触发了一个动画，Core Animation会将该图层对应的位图数据和图层的状态信息发送给图形处理硬件。图形处理器所做的工作是根据获得的信息对位图进行渲染
>  对基于视图的绘图，对视图的改变经常会触发调用视图的drawRect：方法以重绘视图内容。但是此种方式的代价相对较高，因为它是CPU在主线程上的操作。Core Animation通过尽可能的使用图形硬件操纵缓存后的位图来避免了这种开销，从而完成相同或相似的效果。

> Core Animation让视图和可视对象的变化能以动画的形式呈现。大部分变化都与可视对象属性的更改相关。比如Core Animation能让视图的位置、尺寸或者透明度的变化以动画的形式呈现。当你更改了这些属性的值， Core Animation会在当前属性值和最新指定的属性值之间进行动画。

**UIView &&CALAyer区别和联合**
**关系:**

-  官方文档:
   The view system in iOS is built directly on top of Core Animation layers.  Every instance of UIView automatically creates an instance of a
   CALayer class .
   UIView是对layer进一步封装，增加了响应用户时间能力(uiresponder)，包装了一层calyer
   UIView依赖于calyer提供内容，UIVIEW的内容展示(frame.bounds)和动画都是通过calyer获得


**为什么要 UIView 和 CALayer：**
职责分离，避免重复的代码
底层的布局动画是一样的，表层的用户交互事件差异很大，共享代码
- 需要提供什么功能（机制）”和“怎样实现这些功能（策略）”。如果程序可以由独立的部分分别完成机制与策略的实现，那么开发软件就更加容易，也更加容易适应不同的需求。UIView可以看做是策略，变动很多。越是底层，越是机制，越是机制就越是稳定。


*CALayer 的 position 属性与 anchorPoint 属性间的关系*
position是layer中的anchorPoint点在superLayer中的位置坐标。
因此可以说,
**position点是相对suerLayer的，anchorPoint点是相对layer的，**两者是相对不同的坐标空间的一个重合点。
- 1.position是layer中的anchorPoint在superLayer中的位置坐标。
- 2.互不影响原则：单独修改position与anchorPoint中任何一个属性都不影响另一个属性。


它主要的作用就是用来作为变换的支点，



####CoreAnimation
![图片1](http://img.objccn.io/issue-3/pixels-software-stack.png)

1.它是什么:
+ It is an infrastructure for compositing and manipulating your app’s content in hardware.
+ 操作的对象是图层

>  Core Animation是一个复合引擎，它的职责就是尽可能快地组合屏幕上不同的可视内容，这个内容是被分解成独立的图层，存储在一个叫做图层树的体系之

> Core Animation自身并不是一个绘图系统。它只是一个负责在硬件上合成和操纵应用内容的基础构件。（Core Animation is not a drawing system itself. It is an infrastructure for compositing and manipulating your app’s content in hardware.）Core Animation的核心是图层对象，图层对象用于管理和操控你的应用内容。图层将捕获的内容放到一副位图中，**图形硬件能够非常容易的操控你的位图。**（A layer captures your content into a bitmap that can be manipulated easily by the graphics hardware.）在大部分应用中，图层被作为一种管理视图内容的方式，但是你也可以创建标准的图层，

**什么是Animation(动画),简单点说就是在一段时间内,显示的内容发生了变化.对CALayer来说就是在一段时间内,其Animatable Property发生了变化.**


###隐式动画

*之所以叫隐式是因为我们并没有指定任何动画的类型。我们仅仅改变了一个属性，然后Core Animation来决定如何并且何时去做动画*

> 核心动画的隐式动画模型假定所有动画图层属性的变化应该是渐进的和异步的。
> 动态的动画场景可以在没有显式的动画图层时候实现。改变可动画显示的图层的属性
> 将会导致图层隐式把图层从旧的值动画显示为新的值。虽然动画是持续的，但是设置
> 新的目标值时会导致图层从当前状态动画过渡到新的目标值。


> 不同于隐式动画，隐式动画会更新图层对象的值。**而显示动画不会更改图层树中的数据。显示动画仅是创建了一个动画。在动画结束之后，Core Animation从图层中移除该动画对象并使用当前的数据值重绘图层。**如果你想让显示动画的改变成为永久性的，如你在之前的例子中看到的，你必须更新图层属性。

###事务
> 事务实际上是Core Animation用来包含一系列属性动画集合的机制，任何用指定事务去改变可以做动画的图层属性都不会立刻发生变化，而是当事务一旦提交的时候开始用一个动画过渡到新值。

---
> ** 图层的每个改变都是事务的一部分**。CATransaction 是核心动画类，它负责成批的把多个图层树的修改作为一个原子更新到渲染树。
> 可以通过给 CATransaction 类发送一个 begin 消息来创建一
> 个显式事务，修改完成之后发送 comit 消息。
> **Core Animation在每个run loop周期中自动开始一次新的事务（run loop是iOS负责收集用户输入，处理定时器或者网络事件并且重新绘制屏幕的东西），即使你不显式的用[CATransaction begin]开始一次事务，任何在一次run loop循环中属性的改变都会被集中起来，然后做一次0.25秒的动画。**


> UIView+animateWithDuration:animations:。这样写对做一堆的属性动画在语法上会更加简单，但实质上它们都是在做同样的事情。  CATransaction的+begin和+commit方法在+animateWithDuration:animations:内部自动调用，这样block中所有属性的改变都会被事务所包含。这样也可以避免开发者由于对+begin和+commit匹配的失误造成的风险。
> 使用场景：
- 显式事务在同时设置多个图层的属性的
  时候（例如当布局多个图层的时候），
- 暂时的禁用图层的行为
- 或者暂时修改动画的时间的时候


#### CALayer
#####CAShapeLayer
> CAShapeLayer是一个通过矢量图形而不是bitmap来绘制的图层子类。你指定诸如颜色和线宽等属性，用CGPath来定义想要绘制的图形，最后CAShapeLayer就自动渲染出来
> 优点：
- 渲染快速。CAShapeLayer使用了硬件加速，绘制同一图形会比用Core Graphics快很多。
- 高效使用内存。一个CAShapeLayer不需要像普通CALayer一样创建一个寄宿图形，所以无论有多大，都不会占用太多的内存。
- 不会被图层边界剪裁掉。一个CAShapeLayer可以在边界之外绘制。你的图层路径不会像在使用Core Graphics的普通CALayer一样被剪裁掉（如我们在第二章所见）。
- 不会出现像素化。当你给CAShapeLayer做3D变换时，它不像一个有寄宿图的普通图层一样变得像素化。

#### mask
CALayer拥有mask属性，Apple的官方解释如下：

> An optional layer whose alpha channel is used to mask the layer’s content. The layer’s alpha channel determines how much of the layer’s content and background shows through. Fully or partially opaque pixels allow the underlying content to show through but fully transparent pixels block that content.

mask同样也是一个CALayer。假设将CALayer本身称为ContentLayer，将mask称为MaskLayer，蒙版（Masking）的工作原理是通过MaskLayer的alpha值定义ContentLayer的显示区域：对于ContentLayer上每一个Point，计算公式为ResultLayer = ContentLayer * MaskLayer_Alpha。所以当alpha为1时Content显示，alpha为0时Content不显示，其他处于0与1之间的值导致Content半透明。

需要注意的是：

- MaskLayer的color不重要，主要使用opacity（CALayer中的alpha），但是注意[UIColor clearColor]其实就是alpha为0的color。
  ContentLayer超出MaskLayer以外的部分不会被显示出来。
- MaskLayer必须是个“单身汉”，不能有sublayers，否则蒙版（Masking）的结果就是未知（Undefined）。

####粒子动画
> 通常粒子系统在三维空间中的位置与运动是由发射器控制的。发射器主要由一组粒子行为参数以及在三维空间中的位置所表示。**粒子行为参数可以包括粒子生成速度（即单位时间粒子生成的数目）、粒子初始速度向量（例如什么时候向什么方向运动）、粒子寿命（经过多长时间粒子湮灭）、粒子颜色、在粒子生命周期中的变化以及其它参数等等。使用大概值而不是绝对值的模糊参数占据全部或者绝大部分是很正常的，一些参数定义了中心值以及允许的变化**。


####备注：
bitMap:由像素点构成，每个像素点由自己的颜色和位置属性



#### animationGroup

#####  

> The duration of the grouped animations are not scaled to the duration of their [`CAAnimationGroup`](https://developer.apple.com/documentation/quartzcore/caanimationgroup). Instead,* the animations are clipped to the duration of the animation group*. For example, a 10 second animation grouped within an animation group with a duration of 5 seconds displays only the first 5 seconds of the animation
