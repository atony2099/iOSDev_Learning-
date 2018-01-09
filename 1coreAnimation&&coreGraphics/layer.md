---
title: CAReplicatorLayer && CAShapeLayer
date: 2016-01-22 14:24:17
tags:
---



参考：[CAReplicatorLayer](http://blog.csdn.net/u014084081/article/details/49421011)

#### CAReplicatorLayer

1. `CAReplicatorLayer`的目的是为了高效生成许多相似的图层。它会绘制一个或多个图层的子图层，并在每个复制体上应用不同的变换。


1. 相关属性: 
   - `instanceCount`: 子层总数（包括原生子层）
   - `instanceDelay`: 复制子层动画延迟时长
   - `instanceTransform`: 复制子层形变(不包括原生子层)，每个复制子层都是相对上一个。
   - `instanceRedOffset、instanceGreenOffset、instanceBlueOffset、instanceAlphaOffset`: 颜色通道偏移量，每个复制子层都是相对上一个的偏移量。



#### CAReplicatorLayer例子

实现一个音乐振幅条的效果:

![](http://7xrn7f.com1.z0.glb.clouddn.com/16-7-22/81481818.jpg)

相关代码如下: 

```objective-c
- (void)viewDidLoad {
    [super viewDidLoad];
   
    // 创建CAReplicatorLayer对象
    CAReplicatorLayer *layer = [CAReplicatorLayer layer];
    layer.frame = CGRectMake(50, 50, 200, 200);
    layer.backgroundColor = [UIColor blueColor].CGColor;
    [self.view.layer addSublayer:layer];

    // 添加子layer
    CALayer *bar = [CALayer layer];
    bar.backgroundColor = [UIColor redColor].CGColor;
    bar.bounds = CGRectMake(0, 0, 30, 100);
    bar.position = CGPointMake(15, 200);
    bar.anchorPoint = CGPointMake(0.5, 1);
    [layer addSublayer:bar];
    
    // 子layer执行动画操作
    CABasicAnimation *anim = [CABasicAnimation animation];
    anim.keyPath = @"transform.scale.y";
    anim.toValue = @(0.1);
    anim.autoreverses = YES;
    anim.repeatCount = MAXFLOAT;
    [bar addAnimation:anim forKey:nil];
    
    // 复制3个子layer+原来子layer = 4；
    layer.instanceCount = 4;
    // 子laye执行的动画进行延时操作
    layer.instanceDelay = 0.3f;
    // 子layer进行位移操作
    layer.instanceTransform = CATransform3DMakeTranslation(40, 0, 0);
}
```

#### CAShapeLayer

普通CALayer在被初始化时是需要给一个frame值的,这个frame值一般都与给定view的bounds值一致,它本身是有形状的,而且是矩形.

CAShapeLayer在初始化时也需要给一个frame值,但是,它本身没有形状,它的形状来源于你给定的一个path,然后它去取CGPath值,它与CALayer有着很大的区别。

CAShapeLayer有着几点很重要:

-  它依附于一个给定的path,必须给与path,而且,即使path不完整也会自动首尾相接


- strokeStart以及strokeEnd代表着在这个path中所占用的百分比


- CAShapeLayer动画仅仅限于沿着边缘的动画效果,它实现不了填充效果

![](http://i2.piimg.com/567571/bb1e26e70397fc34.png)

##### CAShapeLayer例子

```objective-c
- (void)viewDidLoad {
    [super viewDidLoad];
	CGPoint startPoint = CGPointMake(50, 300);
    CGPoint endPoint = CGPointMake(300, 300);
    CGPoint controlPoint = CGPointMake(170, 200);
    
    //贝塞尔曲线
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:startPoint];
    [path addQuadCurveToPoint:endPoint controlPoint:controlPoint];
    
    //shaperLayer相关属性设置
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = [UIColor redColor].CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth = 5;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.path = path.CGPath; //路径
    [self.view.layer addSublayer:shapeLayer];
	
  // 添加动画效果
    CABasicAnimation *rBase = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    rBase.fromValue = @0.0;
    rBase.toValue = @1;
    rBase.duration = 2.f;
    [shapeLayer addAnimation:rBase forKey:nil];
}
```

#### CAGradientLayer

> 是干嘛的: 处理颜色过度的一个layer

基本属性

1. 方向: startpoint endpoint
2. 颜色组合: colors 
3. 颜色分布区间: locations

Gradient: 梯度

> `CAGradientLayer`是用来生成两种或更多颜色平滑渐变的渐变