---
title: ReactiveCocoa学习笔记
date: 2016-12-25
tags:
---

**参考文档**:

[iOS与函数式编程](http://mrpeak.cn/blog/functional/)

[ReactiveCocoa 中 RACSignal 所有变换操作底层实现分析(上)](https://gold.xitu.io/post/583907a961ff4b006cafce82)

[ReactiveX/RxJava文档中文版](http://mcxiaoke.gitbooks.io/rxdocs/content/)

[RACSignal的Subscription深入分析](http://tech.meituan.com/RACSignalSubscription.html)



#### 基础概念

##### side effects(副作用)

>  In [computer science](https://en.wikipedia.org/wiki/Computer_science), a [function](https://en.wikipedia.org/wiki/Subroutine) or [expression](https://en.wikipedia.org/wiki/Expression_(programming)) is said to have a **side effect** if it modifies some [state](https://en.wikipedia.org/wiki/State_(computer_science)) outside its scope or has an *observable* interaction with its calling functions or the outside world
>
>  For example, a particular function might modify a [global variable](https://en.wikipedia.org/wiki/Global_variable) or [static variable](https://en.wikipedia.org/wiki/Static_variable), modify one of its arguments, raise an exception, write data to a display or file, read data, or call other side-effecting functions.
>
>  简单理解: 一个函数的影响应控制在它的作用域内，它在执行过程中不应该依赖外部或者对外部产生影响
>
>  常见的副作用
>
>  1. 影响了外部变量，比如全局变量
>  2. 函数执行过程中依赖外部变量
>  3. 其他外部影响:函数执行中，log出信息，写入了文件，触发了网络请求，更新了屏幕

##### referential transparency(引用透明)

> [What is referential transparency?](http://stackoverflow.com/questions/210835/what-is-referential-transparency)
>
> Referential transparency, a term commonly used in functional programming, means that given a function and an input value, you will always receive the same output. That is to say there is no external state used in the function.
>
> Here is an example of a referential transparent function:
>
> ```
> int plusOne(int x)
> {
>   return x+1;
> }
> ```
>
> With a referential transparent function, given an input and a function, you could replace it with a value instead of calling the function. So instead of calling plusOne with a paremter of 5, we could just replace that with 6.
>
> Another good example is mathematics in general. In mathematics given a function and an input value, it will always map to the same output value. f(x) = x + 1. Therefore functions in mathematics are referentially transparent.
>
> - 简单理解: 引用透明，函数输入相同参数总是得到相同的结果.
>
>   func(A) = 5, func(A)可以用5来代替

##### pure function

>  **a pure function is referentially transparent and has no side effects**
>
> 纯函数是具备引用透明 和没有副作用的函数
>

##### First Class

> > In [computer science](https://en.wikipedia.org/wiki/Computer_science), a [programming language](https://en.wikipedia.org/wiki/Programming_language) is said to have **first-class functions** if it treats [functions](https://en.wikipedia.org/wiki/Function_(programming)) as [first-class citizens](https://en.wikipedia.org/wiki/First-class_citizen). Specifically, this means the language supports passing functions as arguments to other functions, returning them as the values from other functions, and assigning them to variables or storing them in data structures.[1](https://en.wikipedia.org/wiki/First-class_function#cite_note-1)
>
> 函数: 普通公民 
>
> 变量:一等公民
>
> 函数编程的一等公民: 函数可以像变量那样自由传递(当做参数或者返回值)
>

##### 信号

reactive cocoa 主要操作的是信号。

>  **信号**:可以把信号想象成水龙头，只不过里面不是水，而是玻璃球(value)，直径跟水管的内径一样，这样就能保证玻璃球是依次排列，不会出现并排的情况(数据都是线性处理的，不会出现并发情况)。水龙头的开关默认是关的，除非有了接收方(subscriber)，才会打开。这样只要有新的玻璃球进来，就会自动传送给接收方。可以在水龙头上加一个过滤嘴(filter)，不符合的不让通过，也可以加一个改动装置，把球改变成符合自己的需求(map)。也可以把多个水龙头合并成一个新的水龙头(combineLatest:reduce:)，这样只要其中的一个水龙头有玻璃球出来，这个新合并的水龙头就会得到这个球。



#### 信号操作

![](https://mcxiaoke.gitbooks.io/rxdocs/content/images/legend.png)

> 在ReactiveX中，一个观察者(Observer)订阅一个可观察对象(Observable)。观察者对Observable发射的数据或数据序列作出响应。这种模式可以极大地简化并发操作，因为它创建了一个处于待命状态的观察者哨兵，在未来某个时刻响应Observable的通知，不需要阻塞等待Observable发射数据。
>
> RAC定义了一种变换和获取数据的方式: 一个观察者订阅一个可观察对象 (An observer(Subscriber) subscribes to an Observable)。

##### 变换操作

###### Map

![](https://mcxiaoke.gitbooks.io/rxdocs/content/images/operators/map.png)

```objective-c
RACSignal *originlSignal= [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    [subscriber sendNext:@1];
    [subscriber sendNext:@2];
    [subscriber sendCompleted];
    return nil;
}];

RACSignal *mapSignal = [originlSignal map:^id(NSNumber *value) {
    return @([value intValue] +1);
}];
// output:2,3
[mapSignal subscribeNext:^(id x) {
    NSLog(@"%@",x);
}];
```

##### 过滤操作

###### Filter

Filter:只发射通过了谓词测试的数据项

![](https://mcxiaoke.gitbooks.io/rxdocs/content/images/operators/filter.c.png)

```objective-c
    RACSignal *signalP= [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendNext:@2];
        [subscriber sendCompleted];
        return nil;
    }];
	RACSignal *signalG = [signalP filter:^BOOL(NSNumber *value) {
        return [value intValue] > 1;
    }];
	// output:2
    [signalG subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
```

###### throttle

指定时间内，产生A信号，紧接着产生B信号，这时候A信号就会被抛弃，

如果在指定时间内，再也没有产生新信号，则B信号会一直保留直到指定时间到达

![](http://ohbzayk4i.bkt.clouddn.com/17-1-23/23396068-file_1485141818101_8d8f.png)

```objective-c
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber){
        [subscriber sendNext:@"🐹1"];
        
        [[RACScheduler mainThreadScheduler] afterDelay:0.9 schedule:^{
            [subscriber sendNext:@"🐹2"];
        }];
        
        [[RACScheduler mainThreadScheduler] afterDelay:2.5 schedule:^{
            [subscriber sendNext:@"🐹3"];
            [subscriber sendNext:@"🐹4"];
            [subscriber sendNext:@"🐹5"];
        }];
        
        return nil;
    }] throttle:1] subscribeNext:^(id x) {
      	// 🐹2通过了, 🐹5通过了
        NSLog(@"%@通过了",x);
    }] ;
```

###### distinctUntilChanged

判定一个数据和它的直接前驱是否是不同的。

![](https://mcxiaoke.gitbooks.io/rxdocs/content/images/operators/distinctUntilChanged.png)

```objective-c
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendNext:@1];
        [subscriber sendNext:@2];
        [subscriber sendNext:@2];
        [subscriber sendNext:@3];
        return nil;
    }];
	// outPut: 1, 2, 3
    [[signalA  distinctUntilChanged]subscribeNext:^(NSNumber *x) {
        NSLog(@"%@",x);
    }];
```

###### skip

忽略前N项

![](https://mcxiaoke.gitbooks.io/rxdocs/content/images/operators/skip.png)

```objective-c
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendNext:@2];
        [subscriber sendNext:@3];
        [subscriber sendNext:@4];
        [subscriber sendNext:@5];
        return nil;
    }];
    // outPut: 4,5
    [[signalA  skip:3]subscribeNext:^(NSNumber *x) {
        NSLog(@"%@",x);
    }];
```



###### take

与skip相反，只保留前N项

![](https://mcxiaoke.gitbooks.io/rxdocs/content/images/operators/take.png)

```objective-c
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendNext:@2];
        [subscriber sendNext:@3];
        [subscriber sendNext:@4];
        [subscriber sendNext:@5];
        return nil;
    }];
    // outPut: 1,2,3
    [[signalA  take:3]subscribeNext:^(NSNumber *x) {
        NSLog(@"%@",x);
    }];
```



##### 组合操作

关注的问题: 

- 受那个信号终止而终止
- 错误传递
- 各个信号何时开始订阅

###### concat：

必须等待第前一个信号结束

![](http://ohbzayk4i.bkt.clouddn.com/Jietu20170122-191924.jpg)

```objective-c

   RACSignal *singalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       [subscriber   :@1];
        [subscriber sendCompleted];
       return nil;
    }];
    RACSignal *singalB= [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@2];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *singalC = [singalA concat:singalB];
	// OUTPUT : 1,2,
    [singalC subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
```

###### merge

哪个先到输出哪个

![](http://ohbzayk4i.bkt.clouddn.com/Jietu20170123-025345.jpg)

```objective-c
    RACSubject *subject1 = [RACSubject subject];
    RACSubject *subject2 = [RACSubject subject];
    RACSignal *signal =  [RACSignal merge:@[subject1, subject2]];
    // OUTPUT : 1,2,3,4
    [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    [subject1 sendNext:@1];
    [subject2 sendNext:@2];
    [subject1 sendNext:@3];
    [subject2 sendNext:@4];
```

###### zip

> The first value of each stream will be combined, then the second value, and so forth, until at least one of the streams is exhausted. **它按照严格的顺序组合信号，只有当原始的Observable中的每一个都发射了一条数据时`zip`才发射数据,想象成拉链，一环扣一环**

![](http://ohbzayk4i.bkt.clouddn.com/Jietu20170123-040639.jpg)

```objective-c
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendNext:@2];
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@3];
        [subscriber sendNext:@4];
        [subscriber sendNext:@5];
        return nil;
    }];
    // outPut(1,3),(2,4),
    [[signalA zipWith:signalB] subscribeNext:^(NSNumber *x) {
        NSLog(@"%@",x);
    }];
```

###### combineLatest

组合的数值总是保持最新的

> 当原始Observables的任何一个发射了一条数据时，`CombineLatest`使用一个函数结合它们最近发射的数据，然后发射这个函数的返回值

![](http://ohbzayk4i.bkt.clouddn.com/Snip20170123_1.png)

```objective-c
   
    RACSubject *subject1 = [RACSubject subject];
    RACSubject *subject2 = [RACSubject subject];
    RACSignal *signal =  [RACSignal combineLatest:@[subject1, subject2]];
    
    // output: ractuple(1,11), ractuple(1,2),ractuple(3,11), ractuple3,4),
    [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    [subject1 sendNext:@1];
    [subject2 sendNext:@11];
    [subject2 sendNext:@2];
    [subject1 sendNext:@3];
    [subject2 sendNext:@4]; 
```



#####  高阶信号的操作

![](http://ohbzayk4i.bkt.clouddn.com/17-1-23/55592449-file_1485132732496_ef3a.png)

[1,2,3,[3,4],5] 

数组的数组: 数组里面是数组

高阶信号: 信号流里面还是信号,好比水龙头里面流动还是水龙头，必须对他们进行降阶，转换成玻璃球

###### Switchtolasts

> 关键点:新的信号开始被订阅时候，前一个信号会被取消订阅。

![](http://ohbzayk4i.bkt.clouddn.com/17-1-23/77510402-file_1485133672444_3a17.png)

```objective-c
    RACSubject *letters = [RACSubject subject];
    RACSubject *numbers = [RACSubject subject];
    RACSignal *signalOfSignals = [RACSignal createSignal:^ RACDisposable * (id<RACSubscriber> subscriber) {
        [subscriber sendNext:letters];
        [subscriber sendNext:numbers];
        [subscriber sendCompleted];
        return nil;
    }];
    
    // 信号压平了
    RACSignal *switched = [signalOfSignals switchToLatest];
    // Outputs: 1,2  信号numbers开始被订阅,信号letters就被取消了
    [switched subscribeNext:^(NSString *x) {
        NSLog(@"%@", x);
    }];
    [letters sendNext:@"A"];
    [numbers sendNext:@"1"];
    [letters sendNext:@"B"];
    [letters sendNext:@"C"];
    [numbers sendNext:@"2"];
```



###### Flatten

> 关键点: 各个信号都会被降解，不会被取消

![](http://ohbzayk4i.bkt.clouddn.com/17-1-24/53245742-file_1485258981093_15afe.png)

```
    
    RACSubject *letters = [RACSubject subject];
    RACSubject *numbers = [RACSubject subject];
    RACSignal *signalOfSignals = [RACSignal createSignal:^ RACDisposable * (id<RACSubscriber> subscriber) {
        [subscriber sendNext:letters];
        [subscriber sendNext:numbers];
        [subscriber sendCompleted];
        return nil;
    }];
    
    // 信号压平了
    RACSignal *flattened = [signalOfSignals flatten];
    
    // Outputs: A,1,B,C,2
    [flattened subscribeNext:^(NSString *x) {
        NSLog(@"%@", x);
    }];
  
    [letters sendNext:@"A"];
    [numbers sendNext:@"1"];
    [letters sendNext:@"B"];
    [letters sendNext:@"C"];
    [numbers sendNext:@"2"];
```





#### 订阅过程简析

###### 步骤一：[RACSignal createSignal]来获得signal

```objective-c
RACSignal.m中：
+ ( RACSignal *)createSignal:( RACDisposable * (^)( id < RACSubscriber > subscriber))didSubscribe {
  return [ RACDynamicSignal   createSignal :didSubscribe];
}
RACDynamicSignal.m中
+ ( RACSignal *)createSignal:( RACDisposable * (^)( id < RACSubscriber > subscriber))didSubscribe {
  RACDynamicSignal *signal = [[ self   alloc ] init ];
 signal-> _didSubscribe = [didSubscribe copy ];
  return [signal setNameWithFormat : @"+createSignal:" ];
}
```

[RACSignal createSignal]会调用子类RACDynamicSignal的createSignal来返回一个signal，

并在signal中保存后面的 didSubscribe这个block

###### 步骤二：[signal subscribeNext:]来获得subscriber，然后进行subscription

```objective-c
RACSignal.m中：
- ( RACDisposable *)subscribeNext:( void (^)( id x))nextBlock {
  RACSubscriber *o = [ RACSubscriber   subscriberWithNext :nextBlock error : NULL   completed : NULL ];
  return [ self  subscribe :o];
}
RACSubscriber.m中：

+ ( instancetype )subscriberWithNext:( void (^)( id x))next error:( void (^)( NSError *error))error completed:( void (^)( void ))completed {
  RACSubscriber *subscriber = [[ self   alloc ] init ];
 subscriber-> _next = [next copy ];
 subscriber-> _error = [error copy ];
 subscriber-> _completed = [completed copy ];
  return subscriber;
}
RACDynamicSignal.m中：
- (RACDisposable *)subscribe:(id<RACSubscriber>)subscriber {
    RACCompoundDisposable *disposable = [RACCompoundDisposable compoundDisposable];
    subscriber = [[RACPassthroughSubscriber alloc] initWithSubscriber:subscriber signal:self disposable:disposable];
    if (self.didSubscribe != NULL) {
        RACDisposable *schedulingDisposable = [RACScheduler.subscriptionScheduler schedule:^{
          	// 入参
            RACDisposable *innerDisposable = self.didSubscribe(subscriber);
            [disposable addDisposable:innerDisposable];
        }];
        [disposable addDisposable:schedulingDisposable];
    }
    return disposable;
}
```

1. [signal subscribeNext]先会获得一个subscriber，这个subscriber中保存了nextBlock、errorBlock、completedBlock
2. 由于signal其实是RACDynamicSignal类型的，这个[self subscribe]方法会调用步骤一中保存的didSubscribe，didSubscribe的参数就是1中的subscriber

###### 步骤三：进入didSubscribe，通过[subscriber sendNext:]来执行next block

```objective-c
RACSubscriber.m中：
- (void)sendNext:(id)value {
    @synchronized (self) {
        void (^nextBlock)(id) = [self.next copy];
        if (nextBlock == nil) return;
        nextBlock(value);
    }
}
```

> didsubiscribeblock的[subscriber send:@1] 的实际执行者就是上一步的那个subscriber