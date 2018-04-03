---
title: NSCache
date: 2016-1-20 13:28:35
tags:
---

NSCache是什么？

> An NSCache object is a mutable  collection that stores key-value pairs, similar to an NSDiuctionary object. The NSCache class provides a programmatic interface to adding and removing objects and setting eviction policies based on the total cost and number of objects in the cache.

> 批阅: NSCache是类似于字典的 key-value 存储集合

> The NSCache class incorporates various auto-eviction policies, which ensure that a cache doesn’t use too much of the system’s memory. If memory is needed by other applications, these policies remove some items from the cache, minimizing its memory footprin
>
> You can add, remove, and query items in the cache from different threads without having to lock the cache yourself.
>
> Unlike an NSMutableDictionary object, a cache does not copy the key objects that are put into it.

> 批阅：NSCache的特点
>
> - 线程安全
> - 自动释放机制



```swift
        
        let cache = NSCache<AnyObject, AnyObject>()
        cache.countLimit = 2
        
        for i in 0..<3{
            cache .setObject(i as AnyObject, forKey: "cache\(i)" as AnyObject)  
        }
     
        for i in 0..<3{
            let value = cache.object(forKey: "cache\(i)" as AnyObject)
            print(value)
        }
        // 输出结果 ：nil，Optional(1)，Optional(2)
```





本地相关demo:  CellSizeCacheDemo

参考: [Objective-C中的缓存](http://www.15yan.com/story/45toOUzFGlr/)

