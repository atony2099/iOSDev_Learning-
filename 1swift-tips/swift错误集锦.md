---
title: swift 错误集锦
date: 2016-05-01 00:22:12
tags:
---

#### 1. Variable declared in 'guard' condition not usable in its body

**example**

```swift
 //check to see if we got a valid response code
    guard let resCode = (response as? NSHTTPURLResponse)?.statusCode where resCode == 200 else {
        return NSError(domain: "Error with request", code: 1, userInfo: [NSLocalizedDescriptionKey: "Recieved the following status code: \(resCode)"])
    }
```



**Answer**

As the error states, you can't use a variable that you bound in the guard statement inside of the guard statement's body. The variable only gets bound in the case where the guard body is not entered. You also aren't differentiating between the cases where your response is nil and where your status code isn't 200.

You should break the statements into two different checks:

```
guard let httpResponse = response as? NSHTTPURLResponse else {
    return NSError(domain: "Error with request", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid response: \(response)"])
}

guard httpResponse.statusCode == 200 else {
    return NSError(domain: "Error with request", code: 1, userInfo: [NSLocalizedDescriptionKey: "Recieved the following status code: \(httpResponse.statusCode)"])
}
```

Don't try to minimize the number of lines of code at the expense of readability or correctness.