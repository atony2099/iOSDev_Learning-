---
title: window从入门到精通
date: 2017-03-11 14:21:54
tags:
---

> windows
>
> Discussion
>
> This property contains the UIWindow objects currently associated with the app. This list does not include windows created and managed by the system, such as the window used to display the status bar.

> The windows in the array are ordered from back to front by window level; thus, the last window in the array is on top of all other app windows.



> - A `UIWindow` object provides the backdrop for your app’s user interface 
> - provides important event-handling behaviors



> window
>
> Discussion
>
> This property holds the UIWindow object in the windows array that is most recently sent the makeKeyAndVisible message.

干嘛的: 

keywindow 用来显示当前view 和传递事件

