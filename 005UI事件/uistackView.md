
## stackView


### distribution
#### resize size :fill

- Fill makes one subview take up most of the space, while the others remain at their natural size. It decides which view to stretch by examining the content hugging priority for each of the subviews.
> 只拉伸第一个
![](https://spin.atomicobject.com/wp-content/uploads/20160610170335/uistackview-fill.png)

- Fill Equally adjusts each subview so that it takes up equal amount of space in the stack view. All space will be used up.
> 拉伸每一个，拉伸后大家一样大小
![](https://spin.atomicobject.com/wp-content/uploads/20160610172413/uistackview-fill-equally.png)


- Fill Proportionally is the most interesting, because it ensures subviews remain the same size relative to each other, but still stretches them to fit the available space. For example, if one view is 100 across and another is 200, and the stack view decides to stretch them to take up more space, the first view might stretch to 150 and the other to 300 – both going up by 50%.
> 大家都等比例拉伸
![](https://spin.atomicobject.com/wp-content/uploads/20160610173824/uistackview-fill-proportionally-with-landscape.png)



#### keep size: equal
- Equal Spacing adjusts the spacing between subviews without resizing the subviews themselves.
![](https://spin.atomicobject.com/wp-content/uploads/20160610174332/uistackview-equal-spacing2.png)

- Equal Centering attempts to ensure the centers of each subview are equally spaced, irrespective of how far the edge of each subview is positioned.
![](https://spin.atomicobject.com/wp-content/uploads/20160610175016/uistackview-equal-centering2.png)
[](https://spin.atomicobject.com/wp-content/uploads/20160610175016/uistackview-equal-centering2.png)

### alignment :对齐方式
