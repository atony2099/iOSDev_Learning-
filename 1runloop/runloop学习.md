---
title: runloop
date: 2016-04-12 21:32:39
tags:

---
文章来源: 

[走进Run Loop的世界 (一)：什么是Run Loop？](http://chun.tips/blog/2014/10/20/zou-jin-run-loopde-shi-jie-%5B%3F%5D-:shi-yao-shi-run-loop%3F/)

[Threading Programming Guide](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html)

[深入理解RunLoop](http://www.cocoachina.com/ios/20150601/11970.html)



### 基础概念

一般来讲，一个线程执行完一次就退出了。我们需要一种循环机制，让线程处于"work --sleep -- work-- sleep"的状态，runloop正是这种机制的实现。

![](http://www.2cto.com/uploadfile/Collfiles/20160330/2016033009122244.jpg)

> A run loop is an event processing loop that you use to schedule work and coordinate the receipt of incoming events.The purpose of a run loop is to keep your thread busy when there is work to do and put your thread to sleep when there is none.

相关的伪代码如下: 

```c
while (AppIsRunning){
	var message = get_next_message(); 
	process(message)
}
```



### runloop相关细节

#### runloop与线程关系

先上代码: 

```objective-c
1
/// 全局的Dictionary，key 是 pthread_t， value 是 CFRunLoopRef
static CFMutableDictionaryRef loopsDic;
/// 访问 loopsDic 时的锁
static CFSpinLock_t loopsLock;
  
/// 获取一个 pthread 对应的 RunLoop。
CFRunLoopRef _CFRunLoopGet(pthread_t thread) {
    OSSpinLockLock(&loopsLock);
    if (!loopsDic) {
        // 第一次进入时，初始化全局Dic，并先为主线程创建一个 RunLoop。
        loopsDic = CFDictionaryCreateMutable();
        CFRunLoopRef mainLoop = _CFRunLoopCreate();
        CFDictionarySetValue(loopsDic, pthread_main_thread_np(), mainLoop);
    }
     
    /// 直接从 Dictionary 里获取。
    CFRunLoopRef loop = CFDictionaryGetValue(loopsDic, thread));
     
    if (!loop) {
        /// 取不到时，创建一个
        loop = _CFRunLoopCreate();
        CFDictionarySetValue(loopsDic, thread, loop);
        /// 注册一个回调，当线程销毁时，顺便也销毁其对应的 RunLoop。
        _CFSetTSD(..., thread, loop, __CFFinalizeRunLoop);
    }
     
    OSSpinLockUnLock(&loopsLock);
    return loop;
}
  
CFRunLoopRef CFRunLoopGetMain() {
    return _CFRunLoopGet(pthread_main_thread_np());
}
  
CFRunLoopRef CFRunLoopGetCurrent() {
    return _CFRunLoopGet(pthread_self());
}
```

其中pthread_t是一个与线程相关对象，可以看到runloop存在一个全局的字典里面，线程和runloop是一一对应关系。

程序启动会自动调用`CFRunLoopGetMain` 创建主线程的runloop，其他线程如果不调用`CFRunLoopGetCurrent`并不会主动去创建。

#### Runloop mode

> A *run loop mode* is a collection of input sources and timers to be monitored and a collection of run loop observers to be notified
>
> runloop  mode 是一个关于 输入源,定时源 和观察者的集合。

![](http://blog.ibireme.com/wp-content/uploads/2015/05/RunLoop_0.png)

一个runloop包含若干个mode,每个 Mode 又包含若干个 Source/Timer/Observer

**CFRunLoopSourceRef**

 转发异步事件，有两种版本的source : 
- source0 : 只包含了一个回调 (函数指针),不能主动触发事件

- source1: 基于mach_port()，能唤醒进程

  > Mach port 是一个轻量级的进程间通讯方式，可以理解为一个通讯通道，假如同时有几个进程都挂在这个通道上，那么其他进程向这个通道发送消息时，其他进程都能收到。

**CFRunLoopTimerRef**

转发同步事件，包含一个时间长度和一个回调，加入runloop的时候，runloop会注册对应的时间点，当时间点到达的时候,runloop就被唤醒并执行那个回调

**CFRunLoopObserverRef**

观察者，每个观察者都包含了一个回调，当runloop状态发生变化时候，观察者就能通过会回调感受到这个变化

```objective-c
typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
    kCFRunLoopEntry         = (1UL << 0), // 即将进入Loop
    kCFRunLoopBeforeTimers  = (1UL << 1), // 即将处理 Timer
    kCFRunLoopBeforeSources = (1UL << 2), // 即将处理 Source
    kCFRunLoopBeforeWaiting = (1UL << 5), // 即将进入休眠
    kCFRunLoopAfterWaiting  = (1UL << 6), // 刚从休眠中唤醒
    kCFRunLoopExit          = (1UL << 7), // 即将退出Loop
};
```

> autoreleasepool的创建和销毁?
>
> 苹果在主线程runloop注册了连个observer
>
> 第一个observer监听事件是***entry***，回调调用_objc_autoreleasePoolPush() 创建自动释放池
>
> 第二个observer监听两个事件***BeforeWaiting(准备进入休眠)*** 时调用_objc_autoreleasePoolPop() 和 _objc_autoreleasePoolPush() 释放旧的池并创建新池；Exit(即将退出Loop) 时调用 _objc_autoreleasePoolPop() 来释放自动释放池
>
> 

常见的runloop mode模式

| mode名称                      | 运行机制                                     |
| --------------------------- | ---------------------------------------- |
| NSDefaultRunLoopMode        | App的默认 Mode，通常主线程是在这个 Mode 下运行的。         |
| UITrackingRunLoopMode       | 界面跟踪 Mode，用于 ScrollView 追踪触摸滑动，          |
| UIInitializationRunLoopMode | 刚启动 App 时第进入的第一个 Mode，启动完成后就不再使用。        |
| NSRunLoopCommonModes        | 默认包含了NSDefaultRunLoopMode 和UITrackingRunLoopMode |

> 问题： 为什么[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(doTimer1) userInfo:nil repeats:YES];在滑动的时候定时器不走了呢
>
> 1. schedule类方法默认是将timer添加到defaultMode下面 
>
> 2. 根据官方文档： Each time you run your run loop, you specify (either explicitly or implicitly) a particular “mode” in which to run. During that pass of the run loop, only sources associated with that mode are monitored and allowed to deliver their events. (Similarly, only observers associated with that mode are notified of the run loop’s progress.) Sources associated with other modes hold on to any new events until subsequent passes through the loop in the appropriate mode.
>
>    也就是说runloop每次只能运行在一个mode下，该mode下面的timer才能被监听
>
>    而APP滑动的时候切换到UITrackingRunLoopMode,所以timer事件无法被监听到。
>
> 3. 解决方法
>
>    将timer 添加到commonmodes上面去，commonmodes是关于mode的集合，添加到上面的timer就自动添加到defaultmode和trackingMode。
>
>    ​

#### runloop完整的一个周期

![](http://blog.ibireme.com/wp-content/uploads/2015/05/RunLoop_1.png)



```c
// 用DefaultMode启动
void CFRunLoopRun(void) {
    CFRunLoopRunSpecific(CFRunLoopGetCurrent(), kCFRunLoopDefaultMode, 1.0e10, false);
}
 
/// 用指定的Mode启动，允许设置RunLoop超时时间
int CFRunLoopRunInMode(CFStringRef modeName, CFTimeInterval seconds, Boolean stopAfterHandle) {
    return CFRunLoopRunSpecific(CFRunLoopGetCurrent(), modeName, seconds, returnAfterSourceHandled);
}
 
/// RunLoop的实现
int CFRunLoopRunSpecific(runloop, modeName, seconds, stopAfterHandle) {
    
    /// 首先根据modeName找到对应mode
    CFRunLoopModeRef currentMode = __CFRunLoopFindMode(runloop, modeName, false);
    /// 如果mode里没有source/timer/observer, 直接返回。
    if (__CFRunLoopModeIsEmpty(currentMode)) return;
    
    /// 1. 通知 Observers: RunLoop 即将进入 loop。
    __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopEntry);
    
    /// 内部函数，进入loop
    __CFRunLoopRun(runloop, currentMode, seconds, returnAfterSourceHandled) {
        
        Boolean sourceHandledThisLoop = NO;
        int retVal = 0;
        do {
 
            /// 2. 通知 Observers: RunLoop 即将触发 Timer 回调。
            __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopBeforeTimers);
            /// 3. 通知 Observers: RunLoop 即将触发 Source0 (非port) 回调。
            __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopBeforeSources);
            /// 执行被加入的block
            __CFRunLoopDoBlocks(runloop, currentMode);
            
            /// 4. RunLoop 触发 Source0 (非port) 回调。
            sourceHandledThisLoop = __CFRunLoopDoSources0(runloop, currentMode, stopAfterHandle);
            /// 执行被加入的block
            __CFRunLoopDoBlocks(runloop, currentMode);
 
            /// 5. 如果有 Source1 (基于port) 处于 ready 状态，直接处理这个 Source1 然后跳转去处理消息。
            if (__Source0DidDispatchPortLastTime) {
                Boolean hasMsg = __CFRunLoopServiceMachPort(dispatchPort, &msg)
                if (hasMsg) goto handle_msg;
            }
            
            /// 通知 Observers: RunLoop 的线程即将进入休眠(sleep)。
            if (!sourceHandledThisLoop) {
                __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopBeforeWaiting);
            }
            
            /// 7. 调用 mach_msg 等待接受 mach_port 的消息。线程将进入休眠, 直到被下面某一个事件唤醒。
            /// • 一个基于 port 的Source 的事件。
            /// • 一个 Timer 到时间了
            /// • RunLoop 自身的超时时间到了
            /// • 被其他什么调用者手动唤醒
            __CFRunLoopServiceMachPort(waitSet, &msg, sizeof(msg_buffer), &livePort) {
                mach_msg(msg, MACH_RCV_MSG, port); // thread wait for receive msg
            }
 
            /// 8. 通知 Observers: RunLoop 的线程刚刚被唤醒了。
            __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopAfterWaiting);
            
            /// 收到消息，处理消息。
            handle_msg:
 
            /// 9.1 如果一个 Timer 到时间了，触发这个Timer的回调。
            if (msg_is_timer) {
                __CFRunLoopDoTimers(runloop, currentMode, mach_absolute_time())
            } 
 
            /// 9.2 如果有dispatch到main_queue的block，执行block。
            else if (msg_is_dispatch) {
                __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__(msg);
            } 
 
            /// 9.3 如果一个 Source1 (基于port) 发出事件了，处理这个事件
            else {
                CFRunLoopSourceRef source1 = __CFRunLoopModeFindSourceForMachPort(runloop, currentMode, livePort);
                sourceHandledThisLoop = __CFRunLoopDoSource1(runloop, currentMode, source1, msg);
                if (sourceHandledThisLoop) {
                    mach_msg(reply, MACH_SEND_MSG, reply);
                }
            }
            
            /// 执行加入到Loop的block
            __CFRunLoopDoBlocks(runloop, currentMode);
            
 
            if (sourceHandledThisLoop && stopAfterHandle) {
                /// 进入loop时参数说处理完事件就返回。
                retVal = kCFRunLoopRunHandledSource;
            } else if (timeout) {
                /// 超出传入参数标记的超时时间了
                retVal = kCFRunLoopRunTimedOut;
            } else if (__CFRunLoopIsStopped(runloop)) {
                /// 被外部调用者强制停止了
                retVal = kCFRunLoopRunStopped;
            } else if (__CFRunLoopModeIsEmpty(runloop, currentMode)) {
                /// source/timer/observer一个都没有了
                retVal = kCFRunLoopRunFinished;
            }
            
            /// 如果没超时，mode里没空，loop也没被停止，那继续loop。
        } while (retVal == 0);
    }
    
    /// 10. 通知 Observers: RunLoop 即将退出。
    __CFRunLoopDoObservers(rl, currentMode, kCFRunLoopExit);
}
```

> 一些关键点梳理:
>
> 唤醒线程的事件: 
>
> 1. source1(基于mach_port)
> 2. timer事件



#### runloop的应用

1. 界面显示和刷新： runloop注册对应source通过mach port监听信号信号通知，刷新界面(1.frame，透明度等修改 并提交到一个中间态，2,coreanimaiton在RunLoop

   注册一个observer，这个回调在BeforeWaiting 前，会把所有中间态调教到GPU显示)

> VSync 信号由硬件时钟生成,完成一帧显示，需要显示下一个帧，发出一个VSync，每秒钟发出 60 次, 

2. 事件响应链

   ​



