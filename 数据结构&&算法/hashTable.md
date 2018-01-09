---
title: hash table
date: 2015-01-11 23:38:06
tags:数据结构
---



#### 基本定义: 

**散列表**（**Hash table**，也叫**哈希表**），是根据[键](https://zh.wikipedia.org/wiki/%E9%8D%B5)（Key）而直接访问在内存存储位置的[数据结构](https://zh.wikipedia.org/wiki/%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84)。也就是说，它通过计算一个关于键值的函数，将所需查询的数据[映射](https://zh.wikipedia.org/wiki/%E6%98%A0%E5%B0%84)到表中一个位置来访问记录，这加快了查找速度。这个映射函数称做[散列函数](https://zh.wikipedia.org/wiki/%E6%95%A3%E5%88%97%E5%87%BD%E6%95%B0)，存放记录的数组称做**散列表**。

- 若关键字为![k](https://wikimedia.org/api/rest_v1/media/math/render/svg/c3c9a2c7b599b37105512c5d570edc034056dd40)，则其值存放在![f(k)](https://wikimedia.org/api/rest_v1/media/math/render/svg/c36f16f5357aeb5b0fa2fe3040e74282d62f8881)的存储位置上。由此，不需比较便可直接取得所查记录。称这个对应关系![f](https://wikimedia.org/api/rest_v1/media/math/render/svg/132e57acb643253e7810ee9702d9581f159a1c61)为[散列函数](https://zh.wikipedia.org/wiki/%E6%95%A3%E5%88%97%E5%87%BD%E6%95%B0)，按这个思想建立的表为**散列表。**



- 对不同的关键字可能得到同一散列地址，即![k_{1}\neq k_{2}](https://wikimedia.org/api/rest_v1/media/math/render/svg/f2b910a452063a4769272110d8d22cab053d433d)，![f(k_{1})=f(k_{2})](https://wikimedia.org/api/rest_v1/media/math/render/svg/fa1d43b27a17bf57baf12626ad7cfbf8ee9bb96d)，这种现象称为**冲突**（英语：Collision）。


  


> In [computing](https://en.wikipedia.org/wiki/Computing), a **hash table** (**hash map**) is a [data structure](https://en.wikipedia.org/wiki/Data_structure) used to implement an [associative array](https://en.wikipedia.org/wiki/Associative_array), a structure that can map [keys](https://en.wikipedia.org/wiki/Unique_key) to [values](https://en.wikipedia.org/wiki/Value_(computer_science)).

散列技术是在记录的存储为值和和他的关键字之间确定一个对应关心f，f(key) = address

