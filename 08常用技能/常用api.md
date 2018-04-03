
# 执行后台任务
ios进入后台之后都会被暂停线程


```
__block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{

    //1. do some clean
    // 2 end 
    [application endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
}];

```
