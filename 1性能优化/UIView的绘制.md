---
title: UIView的绘制
date: 2016-02-11 10:28:35
tags:

---

#### CPU流程

##### 基础概念

![](http://ohbzayk4i.bkt.clouddn.com/17-1-21/11221206-file_1484987191790_9c88.png)

1. 每一个View都是一个Layer，每一个layer都有一个content，这个content指向一个缓存，叫做backingstore。

   Layer管理位图状态信息

   > A layer merely manages the state information surrounding a bitmap. 

2. 当View绘制的时候，CPU执行drawRect，写入layer的backingstore


##### 例子

```objective-c
   UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(10, 50, 300, 14)];
   label.backgroundColor = [UIColor whiteColor];
   label.font = [UIFont systemFontOfSize:14.0f];
   label.text = @"test";
   [self.view addSubview:label];
```

1.    dirty views

      > 当一个view改变布局或者属性,或者主动调用setneedlaytout/setneeddisplay，这个view就会被标记为dirty views(有毛病的，需要处理),

      ![](http://my.csdn.net/uploads/201207/19/1342691059_7152.jpg)

      ​

   ![](http://ohbzayk4i.bkt.clouddn.com/17-1-21/54271723-file_1484987856789_1150d.png)

2.    苹果注册了一个 Observer 监听 BeforeWaiting(即将进入休眠) ，在obser中对所有的dirtyView执行drawrect

      ```objective-c
      QuartzCore:CA::Transaction::observer_callback:
          CA::Transaction::commit();
              CA::Context::commit_transaction();
                  CA::Layer::layout_and_display_if_needed();
                      CA::Layer::layout_if_needed();
                            [CALayer layoutSublayers];
                            [UIView layoutSubviews];
                      CA::Layer::display_if_needed();
                            [CALayer display];
                            [UIView drawRect];
      ```
      ​

3.    drawrect被调用，通过Core Graphic的的api绘制bitmap，写入layer的backingstore

4.    清空dirty flag标记
5.    当label的内容改变的时候，重新被标志位dirty。




   >  我们的要渲染的layer已经有了bitmap content的时候，这个content一般来说是一个CGImageRef，CoreAnimation会创建一个OpenGL的Texture并将CGImageRef（bitmap）和这个Texture绑定，通过TextureID来标识。
   >
   >  这个对应关系建立起来之后，剩下的任务就是GPU如何将Texture渲染到屏幕上了。
   >
   >  **简而言之，CoreAnimation会将bitmap先转换为GPU可处理的texture**

> **纹理**: 是图形渲染的一道工序，纹理就像贴纸一样贴在物体表面，使得物体更加真实。暂时可以将纹理理解为位图。
>
> ![](http://wiki.jikexueyuan.com/project/modern-opengl-tutorial/images/picture161.jpg)

> 批阅:并不是每个view的渲染过程都要创建backingstore，对于UIView，他显示的东西很简历，不需要创建一个backingstore
>
> 然而你如果重写了UIView 的 drawrect，他一定会创建一个backingstore，占用内存



#### GPU

![](http://vizlabxt.github.io/images/2013/11/QQ20131123-4.png)

> 1. CPU将准备好的bitmap放到RAM里，GPU去搬这快内存到VRAM中处理。
> 2. 合成和渲染texture

##### Compositing：

Compositing是指将多个纹理拼到一起的过程，

两个view叠加在一起，计算公式如下:

> R = S+D*(1-Sa)

R = S+D*(1-Sa)`

`R`: 为最终的像素值

`S`: 代表 上面的Texture（Top Texture）

`D`: 代表下面的Texture(lower Texture)

其中S,D都已经pre-multiplied各自的alpha值。

`Sa`代表Texture的alpha值。

> view层级越复杂，alpha = 1越多，计算越复杂。




#### UIView 和CAlayer区别

- 封装: UIView是在Calayer 基础上进一步封装，每个UIView都有一个RootLayer，

1. UIView一些基础几何属性来自于layer


2. UIView继承了Responder，响应事件

   ​

- 绘制 和 显示: UIView底层调用coreGraphics绘制视图信息，

  - UIView是CAlayer代理
  - 通过calyer的代理方法绘制到calyer的backing store


- 进一步通过CoreAnimaiton 将这些位图信息提交到GPU进行渲染和合成。










参考:  

[理解contentsScale](http://joeshang.github.io/2015/01/10/understand-contentsscale/)

[理解UIView的绘制](http://vizlabxt.github.io/blog/2012/10/22/UIView-Rendering/)

[详解CALayer 和 UIView的区别和联系](http://www.jianshu.com/p/079e5cf0f014)

[OPENGL](https://learnopengl-cn.readthedocs.io/zh/latest/01%20Getting%20started/06%20Textures/)

[iOS Programming: The Big Nerd Ranch Guide (2014)](http://apprize.info/apple/ios/6.html)





