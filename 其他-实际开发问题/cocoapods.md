---
title:cocoa pods
date: 2016-09-11 23:38:06
tags:
---

#### 作用:

 第三方库的依赖管理工具，简化第三方库的管理

#### 安装(升级)：

```
$ sudo gem install cocoapods
$ pod setup
```

```ruby
// 更换ruby源
gem sources --add https://gems.ruby-china.org --remove https://rubygems.org/
gem sources -l
*** CURRENT SOURCES ***
https://ruby.taobao.org
```



#### 相关文件: 

##### Podfile 

依赖配置文件

##### Podfile.lock  

锁定版本,在多人开发的时候防止版本混乱

> This file is generated after the first run of `pod install`, and tracks the version of each Pod that was installed. For example, imagine the following dependency specified in the Podfile:
>
> ```
> pod 'RestKit'
> ```
>
> Running `pod install` will install the current version of RestKit, causing a `Podfile.lock` to be generated that indicates the exact version installed (e.g. `RestKit 0.10.3`). Thanks to the `Podfile.lock`, running `pod install` on this hypothetical project at a later point in time on a different machine will still install RestKit 0.10.3 even if a newer version is available. CocoaPods will honour the Pod version in `Podfile.lock` unless the dependency is updated in the Podfile or `pod update` is called (which will cause a new `Podfile.lock` to be generated)



#### 版本指定逻辑

- `'> 0.1'` Any version higher than 0.1
- `'>= 0.1'` Version 0.1 and any higher version
- `'< 0.1'` Any version lower than 0.1
- `'<= 0.1'` Version 0.1 and any lower version


- `'~> 0.1.2'` Version 0.1.2 and the versions up to 0.2, not including 0.2 and higher
- `'~> 0.1'` Version 0.1 and the versions up to 1.0, not including 1.0 and higher
- `'~> 0'` Version 0 and higher, this is basically the same as not having it.



### 常用指令

```ruby
pod install // 根据Podfile文件指定的内容，安装依赖库，如果有Podfile.lock文件而且对应的Podfile文件未被修改，则会根据Podfile.lock文件指定的版本安装
pod update // 如果Podfile对应的依赖版本不是写死的，会去获取最新版本的依赖库
pod search xxx // 查找第三方库
pod version // 查看cocoapods版本
```



#### .gitignore 

官网建议我们pods都加入到版本控制里面

> Whether or not you check in your `Pods` folder is up to you, as workflows vary from project to project. We recommend that you keep the Pods directory under source control, and don't add it to your `.gitignore`.
>
> .......
>
> Whether or not you check in the `Pods` directory, the `Podfile` and `Podfile.lock` should always be kept under version control.



#### 原理

**CocoaPods的原理是将所有的依赖库都放到另一个名为Pods的项目中，然后让主项目依赖Pods项目，这样，源码管理工作都从主项目移到了Pods项目中**。Pods项目最终会编译成一个名为libPods.a的文件，主项目只需要依赖这个.a文件即可。



#### swift 3.0下的兼容

1. 首先把Cocoapods升级到最新的 >=1.1.0版

2. 把swift的依赖库都改为支持swift3.0的版本

3. 全部target设置Use Legacy Swift Language version为No，重新执行pod install重装pod项目

   ![](http://upload-images.jianshu.io/upload_images/2245498-b37bd4d1e92c9e70.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



参考: 

[Using CocoaPods](http://guides.cocoapods.org/using/using-cocoapods.html#should-i-ignore-the-pods-directory-in-source-control)

