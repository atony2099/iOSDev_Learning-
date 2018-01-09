---
title: UINavigationBar
date: 2015-8-08 19:30:25
tags:

---


![](http://ohbzayk4i.bkt.clouddn.com/16-12-18/79131915-file_1482024380487_ccf5.jpg)

> The UINavigationBar class provides a control for navigating hierarchical content. It’s a bar, typically displayed at the top of the screen, containing buttons for navigating within a hierarchy of screens. The primary properties are a left (back) button, a center title, and an optional right button. You can use a navigation bar as a standalone object or in conjunction with a navigation controller object.





> A UINavigationItem object manages the buttons and views to be displayed in a UINavigationBar object. When building a navigation interface, each view controller pushed onto the navigation stack must have a UINavigationItem object that contains the buttons and views it wants displayed in the navigation bar. The managing UINavigationController object uses the navigation items of the topmost two view controllers to populate the navigation bar with content.

> 如果把导航控制器比作一个剧院，那导航栏就相当于舞台，舞台必然是属于剧院的，所以，导航栏是导航控制器的一个属性。视图控制器（UIViewController）就相当于一个个剧团，而导航项（navigation item）就相当于每个剧团的负责人，负责与剧院的人接洽沟通。显然，导航项应该是视图控制器的一个属性。虽然导航栏和导航项都在做与导航相关的事情，但是它们的从属是不同的。  
>





[【iOS】导航栏那些事儿](http://www.jianshu.com/p/f797793d683f)
