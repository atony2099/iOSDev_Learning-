
iOS11 适配

## self-sizing
```
tableView.estimatedRowHeight = UITableViewAutomaticDimension //( ios11 default value)
tableView.rowHeight = UITableViewAutomaticDimension;（default value）
```
关闭：
```
self.tableView.estimatedRowHeight = 0;
self.tableView.estimatedSectionHeaderHeight = 0;
self.tableView.estimatedSectionFooterHeight = 0;

```

## scrollView insert
automaticallyAdjustsScrollViewInsets ===>  contentInsetAdjustmentBehavior
> which lets container view controllers know that they should adjust the scroll view insets of this view controller’s view to account for screen areas consumed by a status bar, search bar, navigation bar, toolbar, or tab bar. Set this property to NO if your view controller
根据navigationbar  或者 tabbar 调整内边距
ios 11(会根据statusbar 调整,io10不会)
```
if #available(iOS 11.0, *) {
         tableView.contentInsetAdjustmentBehavior = .automatic
     } else {
         // Fallback on earlier versions
         automaticallyAdjustsScrollViewInsets = true

     }
```
