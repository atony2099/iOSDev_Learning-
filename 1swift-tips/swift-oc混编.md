---
title: swift-oc混编
date: 2016-10-01 00:22:12
tags:
---

#### 可选的基本类型无法直接转换为OC数据类型


Optional values of non-Objective-C types aren't bridged into Objective-C. That is, the first three properties of `TestClass` below *would* be available in Objective-C, but the fourth wouldn't:

```
class TestClass: NSObject {
    var nsNumberVar: NSNumber = 0      // obj-c type, ok
    var nsNumberOpt: NSNumber?         // optional obj-c type, ok
    var doubleVar: Double = 0          // bridged Swift-native type, ok
    var doubleOpt: Double?             // not bridged, inaccessible
}
```

In your Objective-C code, you'd access those first three properties like this:

```
TestClass *optTest = [[TestClass alloc] init];
optTest.nsNumberOpt = @1.0;
optTest.nsNumberVar = @2.0;
optTest.doubleVar = 3.0;
```

In your case, you can either convert `lat` and `long` to be non-Optional or switch them to be instances of `NSNumber`  
