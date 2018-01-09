## idfa idfv
### idfa
> 广告标识符:on the same device,all vendor's id are the same  

![](https://upload-images.jianshu.io/upload_images/1638260-c99989dbd47b420a.jpg?imageMogr2/auto-orient/)



### idfv
> on the same device the same vendor's id are the same


### keyChain
[Using The iOS Keychain.
](https://www.andyibanez.com/using-ios-keychain/)
[iOS小熊聊聊iOS Keychain](https://www.cnblogs.com/xiongwj0910/p/7151258.html)


所有app的共享数据库，苹果用来存储wift密码

每种类型的Keychain item都有不同的键作为主要的Key也就是唯一标示符用于搜索，更新和删除，Keychain内部不允许添加重复的Item。

keychain item的类型，也就是kSecClass键的值	主要的Key
kSecClassGenericPassword	kSecAttrAccount,kSecAttrService
