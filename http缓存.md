---
title: http缓存
date: 2016-02-08 01:26:58
tags:
---

#### BASE

Apps that communicate with a server via HTTP usually have two particular requirements:

> don’t make the user wait for data whenever possible, 
>
>  be useful when there is no internet connection

iOS  has the APIs we need to implement response caching and offline mode.

Very little code is required, even less if your server plays nice with cache headers and you’re targeting iOS 7 and above.

The shared `NSURLCache` gives us much out of the box





#### offlineMode 

In most cases, showing old data is better that showing no data (exceptions being weather and stock, for example). 

If we want our offline mode to always return the cached data, then our requests must have a different cache policy, one that uses cache data regardless of its expiration date. Both `NSURLRequestReturnCacheDataDontLoad` and `NSURLRequestReturnCacheDataElseLoad` fit this criteria. In particular, `NSURLRequestReturnCacheDataElseLoad`has the advantage of trying the network if no cached response is found



1. what is cache-Control 



#### Http  Request

1. http  request

   - 请求行
   - 请求头: 
   - 请求体

   > ```c#
   > POST /index.php HTTP/1.1
   > Host: localhost
   > User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:10.0.2) Gecko/20100101 Firefox/10.0.2
   > Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
   > Accept-Language: zh-cn,zh;q=0.5
   > Accept-Encoding: gzip, deflate
   > Connection: keep-alive
   > Referer: http://localhost/
   > Content-Length：25
   > Content-Type：application/x-www-form-urlencoded
   >
   > username=aa&password=1234
   > ```

2. http response

   - 响应行
   - 响应头
   - 响应体

> ```
> HTTP/1.1 200 OK
> Date: Sun, 17 Mar 2013 08:12:54 GMT
> Server: Apache/2.2.8 (Win32) PHP/5.2.5
> X-Powered-By: PHP/5.2.5
> Set-Cookie: PHPSESSID=c0huq7pdkmm5gg6osoe3mgjmm3; path=/
> Expires: Thu, 19 Nov 1981 08:52:00 GMT
> Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0
> Pragma: no-cache
> Content-Length: 4393
> Keep-Alive: timeout=5, max=100
> Connection: Keep-Alive
> Content-Type: text/html; charset=utf-8
>
>
> <html>
> <head>
> <title>HTTP响应示例<title>
> </head>
> <body>
> Hello HTTP!
> </body>
> </html>
> ```



http 的缓存策略  Cache-Control

```c
  Cache-Control: private/public Public 响应会被缓存，并且在多用户间共享。 Private 响应只能够作为私有的缓存，不能再用户间共享。
  Cache-Control: no-cache：不进行缓存 
  Cache-Control: max-age=x：缓存时间 以秒为单位 
  Cache-Control: must-revalidate：如果页面是过期的 则去服务器进行获取。
```











 

http1.0 vs http 1.0  response header

Pragma : no-cache 表示防止客户端缓存，需要强制从服务器获取最新的数据； 
Expires: HTTP1.0 响应头，本地副本缓存过期时间，如果客服端发现缓存文件没有过期则不发送请求，HTTP的日期必须是格林威治时间（GMT）,如"Expires:Wed,14 Mar 2015 14:30:32 GMT" 



Cache-Control 



#### how cache-control work

An [`NSURLCache`](http://nshipster.com/nsurlcache/) `sharedCache` is enabled by default and will be used by any [`NSURLConnection`](https://developer.apple.com/library/mac/documentation/cocoa/reference/foundation/classes/NSURLConnection_Class/Reference/Reference.html)objects fetching URL contents for you.

Unfortunately, it has a tendency to hog memory and does not write to disk in its default configuration. To tame the beast and potentially add some persistance, you can simply declare a shared [`NSURLCache`](http://nshipster.com/nsurlcache/) in your app delegate like so:

```objective-c
NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:2 * 1024 * 1024
                                              diskCapacity:100 * 1024 * 1024
                                              diskPath:nil];
[NSURLCache setSharedURLCache:sharedCache];
```







[How Does Caching Work in AFNetworking? : AFImageCache & NSUrlCache Explained](http://blog.originate.com/blog/2014/02/20/afimagecache-vs-nsurlcache/)

[How to cache server responses in iOS apps](http://www.hpique.com/2014/03/how-to-cache-server-responses-in-ios-apps/)

[HTTP-请求、响应、缓存](https://cnbin.github.io/blog/2016/02/20/http-qing-qiu-,-xiang-ying-,-huan-cun/)

[HTTP请求方法对照表](http://tools.jb51.net/table/http_request_method)
[HTTP in iOS你看我就够](http://www.cocoachina.com/ios/20160525/16438.html)