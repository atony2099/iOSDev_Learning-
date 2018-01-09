---
title: LLDB从入门到放弃
date: 2017-03-07 11:35:35
tags:
---

[与调试器共舞 - LLDB 的华尔兹](https://objccn.io/issue-19-2/)

[熟练使用 LLDB，让你调试事半功倍](http://www.phperz.com/article/16/0119/184198.html)



#### LLDB是什么

开源的调试器

常见的命令

print：

PO : 打印对象


打印堆栈信息

> ```
> breakpoint set -n main
> ```
>
> 这个命令对应到上面的语法就是：
>
> 1. `command`: `breakpoint` 表示断点命令
> 2. `action`: `set` 表示设置断点
> 3. `option`: `-n` 表示根据方法name设置断点
> 4. `arguement`: `mian` 表示方法名为mian
