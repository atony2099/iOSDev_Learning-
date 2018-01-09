---
title: APP启动过程
date: 2015-4-28 22:05:59
tags: 
---

本文探讨的问题？

- 应用程序的启动过程是怎么样？
- 应用程序的生命周期是怎么样？

#### 应用程序的启动过程

![](http://oleb.net/media/xcode-4-2-app-launch-sequence.png)



*图片来源外国网友*

上图比较完整的描绘一个app启动过程，让我们一步一步开始分解

- main函数执行

```c
int main(int argc, char *argv[]){
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
```
main函数是程序的入口，app启动时候先执行main函数，main函数再调用UIApplicationMain函数，

- UIApplicationMain函数这做了很多事情，首先他会创建一个UIAPPlication的单例对象，并创建UIApplication对象的代理对象AppDelegate

  > 苹果已经为把每个应用包装成一个UIApplication对象，但应用每一步运行的细节并不需要开发者关注，只要关注这个应用对象对应的delegate即可，也就是这个“AppDelegate”。通过AppDelegate我们可以知道Application的运行状态，发生了哪些事件。
  >
  > The `UIApplicationDelegate` protocol defines methods that are called by the singleton `UIApplication` object in response to important events in the lifetime of your app.
  >
  > AppDelegate定义了很多app生命周期中的重要事件

  同时他会载入和解析info.plist文件.

  > info.plist是对工程运行期配置的文件，info常见字段有： 
  >
  >    1> Localiztion native development region (CFBundleDevelopmentRegion)-本地化相关;
  >
  >     2> Bundle display name(CFBundleDisplayName)-程序安装后显示的名称,限制在10-12个字符,如果超出,将被显示缩写名称;
  >
  >     3> Icon file(CFBundleIconFile)-app图标名称,一般为Icon.png;
  >
  >     4> Bundle version(CFBundleVersion)-应用程序的版本号,每次往App Store上发布一个新版本时,需要增加这个版本号;
  >
  >     5> Main storyboard file base name(NSMainStoryboardFile)-主storyboard文件名称;
  >
  >     6> Bundle identifier(CFBundleIdentifier)-项目的唯一标识,部署到真机时用到;


- UIApplication 对象创建管理runloop，UIApplication对象通过runloop来处理各种事件，runloop是一个无限循环，使UIApplicationMain()永远不返回

- 在UIApplication 对象开始处理事件之前，它会给它的代理发送一个消息application:didFinishLaunchingWithOptions:告诉代理对象AppDelegate，程序已经启动.

  如果之前info.plist没有指定main stroyboard，这时候我们就需要在该方法里面手动创建keyWindow并设置它的rootViewController，相关代码如下

  ```objective-c
  - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
  {
      self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
      // Override point for customization after application launch.
      self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
      self.window.rootViewController = self.viewController;
      [self.window makeKeyAndVisible];
      return YES;
  }
  ```


#### 应用程序的生命周期

![](https://developer.apple.com/library/ios/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/Art/high_level_flow_2x.png)''

应用程序的状态大概如下: 

| 状态         | 运行机制                                     |
| :--------- | ---------------------------------------- |
| Not Runing | 程序没有启动                                   |
| Inactive   | 过渡的状态，或者被系统打断(短信，电话), ，应用程序不接收消息或事件      |
| Active     | 前台运行的正常状态,能够接收消息和事件                      |
| Background | 进入后台的状态，不会停留太久就会进如挂起状态                   |
| suspended  | 程序在暂停时不能执行代码、但是不会被释放内存。但是当系统内存不足的情况下，暂停的程序有可能会被释放。 |

![](https://developer.apple.com/library/ios/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/Art/app_interruptions_2x.png)



初次启动：

`applicationdidFinishLaunchingWithOptions`
`applicationDidBecomeActive`

按下home键：

`applicationWillResignActive`
`applicationDidEnterBackground`

`applicationWillTerminate` // 即将推出

点击APP重新进入：

`applicationWillEnterForeground`
`applicationDidBecomeActive`



参考文档: 

[iOS application生命周期研究、发现与总结](http://blog.csdn.net/yang8456211/article/details/11662891)

[Revisiting the App Launch Sequence on iOS](http://oleb.net/blog/2012/02/app-launch-sequence-ios-revisited/)

[iOS应用程序的状态及其切换（生命周期)](http://www.molotang.com/articles/1254.html)