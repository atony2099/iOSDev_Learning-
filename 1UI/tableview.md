---
title:UITableView的再认识
date: 2015-9-20 13:28:35
tags: 
---

> ```objective-c
> 1) -(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
> 2) -(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
> 3) -(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
> 4) -(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
> ```





**setNeedsLayout**

\> Call this method on your application’s main thread when you want to adjust the layout of a view’s subviews application’s main thread when you want to adjust the layout of a view’s subviews.

\_cachedCells,

availableCells,

\_reusableCells

```objective-c
// 1. 获取数据源 ---

- (void)setDataSource:(id)newSource

{

 _dataSource = newSource;

 _dataSourceHas.numberOfSectionsInTableView = [_dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)];

 _dataSourceHas.titleForHeaderInSection = [_dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)];

 _dataSourceHas.titleForFooterInSection = [_dataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)];

 _dataSourceHas.commitEditingStyle = [_dataSource respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)];

 _dataSourceHas.canEditRowAtIndexPath = [_dataSource respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)];

 [self _setNeedsReload];

}

​```

// 2. 重新布局

- (void)_setNeedsReload{

 _needsReload = YES;

 [self setNeedsLayout];

}

3. 标记重新布局----
- (void)layoutSubviews
{
    //对子视图进行布局，该方法会在第一次设置数据源调用 setNeedsLayout 方法后自动调用。
    //并且 UITableView 是继承自 UIScrollview ，当滚动时也会触发该方法的调用
    _backgroundView.frame = self.bounds;

    //在进行布局前必须确保 section 已经缓存了所有高度相关的信息
    [self _reloadDataIfNeeded];    

    //对 UITableView 的 section 进行布局，包含 section 的头部，尾部，每一行 Cell
    [self _layoutTableView];

    //对 UITableView 的头视图，尾视图进行布局
    [super layoutSubviews];
}
3. 2. 重新布局
- (void)_reloadDataIfNeeded
{
    if (_needsReload) {
        [self reloadData];
    }
}

3. 2. 1清除所有的缓存对象 
- (void)reloadData
{
    //当数据源更新后，需要将所有显示的UITableViewCell和未显示可复用的UITableViewCell全部从父视图移除，
    //重新创建
    [[_cachedCells allValues] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_reusableCells makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_reusableCells removeAllObjects];
    [_cachedCells removeAllObjects];

    _selectedRow = nil;
    _highlightedRow = nil;

    // 重新计算 section 相关的高度值，并缓存起来
    [self _updateSectionsCache];
    [self _setContentSize];

    _needsReload = NO;
}

4. -- 看不懂 ，看下面的
- (void)_layoutTableView {
........
	NSMutableDictionary *availableCells = [_cachedCells mutableCopy];
    const NSInteger numberOfSections = [_sections count];
    [_cachedCells removeAllObjects];

    for (NSInteger section=0; section 0) {
                //在滚动时，如果向上滚动，除去顶部要隐藏的 Cell 和底部要显示的 Cell，中部的 Cell 都可以
                //根据 indexPath 直接获取
                    UITableViewCell *cell = [availableCells objectForKey:indexPath] ?: [self.dataSource tableView:self cellForRowAtIndexPath:indexPath];
                    if (cell) {
                        [_cachedCells setObject:cell forKey:indexPath];

                        //将当前仍留在可视区域的 Cell 从 availableCells 中移除，
                        //availableCells 中剩下的即为顶部已经隐藏的 Cell
                        //后面会将该 Cell 加入 _reusableCells 中以便下次取出进行复用。
                        [availableCells removeObjectForKey:indexPath];

                        cell.highlighted = [_highlightedRow isEqual:indexPath];
                        cell.selected = [_selectedRow isEqual:indexPath];
                        cell.frame = rowRect;
                        cell.backgroundColor = self.backgroundColor;
                        [cell _setSeparatorStyle:_separatorStyle color:_separatorColor];
                        [self addSubview:cell];
                    }
                }
            }
        }
    }

    //把所有因滚动而不再可视的 Cell 从父视图移除并加入 _reusableCells 中，以便下次取出复用
    for (UITableViewCell *cell in [availableCells allValues]) {
        if (cell.reuseIdentifier) {
            [_reusableCells addObject:cell];
        } else {
            [cell removeFromSuperview];
        }
    }

    //把仍在可视区域的 Cell（但不应该在父视图上显示） 但已经被回收至可复用的 _reusableCells 中的 Cell从父视图移除
    NSArray* allCachedCells = [_cachedCells allValues];
    for (UITableViewCell *cell in _reusableCells) {
        if (CGRectIntersectsRect(cell.frame,visibleBounds) && ![allCachedCells containsObject: cell]) {
            [cell removeFromSuperview];
        }
    }


```



> 1. 每次在创建cell的时候，程序会首先通过调用dequeueReusableCellWithIdentifier:cellType方法，到复用队列中去寻找标示符为“cellType”的cell，如果找不到，返回nil，然后程序去通过调用[[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:cellType] autorelease]来创建标示符为“cellType”的cell。



```objective-c
- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath{
    // 1.  先从重用池去取
    NSMutableArray *array = self.reusableCellsDictionary[identifier];
    UITableViewCell *cell = nil;
    if(array.count){
      2. 如果有的话 直接取重用池 
        cell = array.lastObject;
        [self.visibleCells addObject:cell];
        [array removeLastObject];
        
    }else{
      3. 如果没有，生成一个
        id obj = self.registerCellInfo[identifier];
        if([obj isKindOfClass:[UINib class]]){
            cell = [[((UINib *)obj) instantiateWithOwner:nil options:nil] lastObject];
        }else{
            cell = [[(Class)obj alloc] init];
        }
        if(cell){
            [self.visibleCells addObject:cell];
         }
    }

    return cell;
}
```



#### Scroll vIEW

conceptual

functional

directive