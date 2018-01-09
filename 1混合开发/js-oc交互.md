---
title: js&&oc交互
date: 2016-03-02 15:33:17
tags:
---

#### 相关概念

>  JavaScriptCore是iOS7引入的新功能，JavaScriptCore可以理解为一个浏览器的运行内核，使用JavaScriptCore可以使用native代码（这里主要指objectiveC和swift）与js代码进行相互的调用

```
#import "JSContext.h"
#import "JSValue.h"
#import "JSManagedValue.h"
#import "JSVirtualMachine.h"
#import "JSExport.h"
```

- JSContext是JavaScript的运行上下文，他主要作用是执行js代码和注册native方法接口
- JSValue是JSContext执行后的返回结果，他可以是任何js类型（比如基本数据类型和函数类型，对象类型等），并且都有对象的方法转换为native对象。
- JSManagedValue是JSValue的封装，用它可以解决js和原声代码之间循环引用的问题
- JSVirtualMachine 管理JS运行时和管理js暴露的native对象的内存
- JSExport是一个协议，通过实现它可以完成把一个native对象暴漏给js

#### JS调用OC

JS端实现

```objective-c
//iOSNative 是调用方法的对象，方法名要跟iOS端协商好
//callHandler 这个是function name，方法名称 要和iOS商议确定
//handlerName和info 这个是传过来给iOS的参数
iOSNative.callHandler(info)
```

iOS端实现

```
 #import <Foundation/Foundation.h>  
#import <JavaScriptCore/JavaScriptCore.h>  
  
//首先创建一个实现了JSExport协议的协议  
@protocol JSObjectText <JSExport>  

-(void)callHandler:(NSString *)string;  

@end  
  
//让我们创建的类实现上边的协议  
@interface JSObject : NSObject<JSObjectText>  
@end
```

```
 #import "JSObjectText.h"  
  
@implementation JSObjectText  
  
-(void)callHandler:(NSString *)string;  
{  
	NSLog(@"%@",string) ;
}  

@end
```

```
-(void)webViewDidFinishLoad:(UIWebView *)webView  {  
    //网页加载完成调用此方法  
    //首先创建JSContext 对象（此处通过当前webView的键获取到jscontext）  
    JSContext *context=[webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];  
   
    //假设js是通过iOSNative对象调用
    //首先创建我们新建类的对象，将他赋值给js的对象  
    JSObjectText *iOSNative=[JSObjectText new];  
    context[@"iOSNative"]=iOSNative;        
}
	//异常信息的处理
  context.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息：%@", exceptionValue);
    };
```