---
title: ScrollView的再认识
date: 2015-08-20 13:28:35
tags:
---

> ScrollView 是UI的基础！ ----tony



视图最终渲染的
CompositedPosition.x = View.frame.origin.x - Superview.bounds.origin.x;

CompositedPosition.y = View.frame.origin.y - Superview.bounds.origin.y;


scrollView contentOffset 其实是通过不断改变自身的bouds来达到视图移动的效果

```
  - (void)setContentOffset:(CGPoint)offset
  {
      CGRect bounds = [self bounds];
      bounds.origin = offset;
      [self setBounds:bounds];
  }
```


可视区域

当前scrollview 的size 就是可视区域，当用来显示内容
![](https://objccn.io/images/issues/issue-3/SV5.png)

contentSize展示所有的内容， scollview通过不断改变自己的bounds来遍历contentSize的内容


![](https://objccn.io/images/issues/issue-3/SV6.png
滑动到最小值后，相对可视区域继续下滑
















#### Base

##### contentSize

The `contentSize` property is the size of the content that you need to display in the scroll view. In Creating Scroll Views in Interface Builder, it is set to 320 wide by 758 pixels high. The image in Figure 1-2 shows the content of the scroll view with the `contentSize` width and height indicated.

![](https://developer.apple.com/library/content/documentation/WindowsViews/Conceptual/UIScrollView_pg/Art/contentSize.jpg)

##### contentInset

额外的展示区域，使得contentsize 变大

>  One way of thinking of it is that it makes the scroll view content area larger

![](https://developer.apple.com/library/content/documentation/WindowsViews/Conceptual/UIScrollView_pg/Art/contentSize_contentInset.jpg)
