---
title: Cocoapods
date: 2017-08-11 12:06:25
tags:
---
[](http://www.code4app.com/article/cocoapods-install-usage)

## 是什么
CocoaPods是一个第三方库的管理工具

####
>  sudo gem install cocoapods





### pods

> - `= 0.1` Version 0.1.
> - `> 0.1` Any version higher than 0.1.
> - `>= 0.1` Version 0.1 and any higher version.
> - `< 0.1` Any version lower than 0.1.
> - `<= 0.1` Version 0.1 and any lower version.
> - `~> 0.1.2` Version 0.1.2 and the versions up to 0.2, not including 0.2. This operator works based on *the last component* that you specify in your version requirement. The example is equal to `>= 0.1.2` combined with `< 0.2.0` and will always match the latest known version matching your requirements.

pod install --verbose --no-repo-update: 禁止更新 spec 仓库

[pod install vs. pod update](https://guides.cocoapods.org/using/pod-install-vs-update.html)

###  install vs update

 `Podfile.lock` : 将已经安装的pods版本写入

install. 只会去更新podfole.lock没有罗列的库(版本)，

> pod  YYIMAGE  '0.1'
>
> //更新
>
> pod  YYIMAGE  '0.2' 这个库在lock没有，会去下载

update: 会尝试去更新所有的库

> 安装新库，尽量使用install，会避免把其他库更新了
