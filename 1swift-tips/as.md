---
title: swift as
date: 2016-05-01 00:22:12
tags:
---

as , as!, as?

The as keyword used to do both upcasts and downcasts:

```swift
 // Before Swift 1.2
 var aView: UIView = someView()
 var object = aView as NSObject // upcast 
 var specificView = aView as UITableView // downcast
```
```

The upcast, going from a derived class to a base class, can be checked at compile time and will never fail.

However, downcasts can fail since you can’t always be sure about the specific class. If you have a UIView, it’s possible it’s a UITableView or maybe a UIButton. If your downcast goes to the correct type – great! But if you happen to specify the wrong type, you’ll get a runtime error and the app will crash.

In Swift 1.2, downcasts must be either optional with as? or “forced failable” with as!. If you’re sure about the type, then you can force the cast with as! similar to how you would use an implicitly-unwrapped optional:

```
// After Swift 1.2
var aView: UIView = someView()

var tableView = aView as! UITableView
```

The exclamation point makes it absolutely clear that you know what you’re doing and that there’s a chance things will go terribly wrong if you’ve accidentally mixed up your types!

As always, as? with optional binding is the safest way to go:

​```swift
// This isn't new to Swift 1.2, but is still the safest way
var aView: UIView = someView()

if let tableView = aView as? UITableView {
  // do something with tableView
}
```

[What's the difference between “as?”, “as!”, and “as”?](http://stackoverflow.com/questions/29637974/whats-the-difference-between-as-as-and-as)



