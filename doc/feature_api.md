# diskLruCache4cj库

## 介绍

DiskLruCache 是一个管理硬盘内容的存储管理工具，它采用了最近最少使用（LRU）算法，以对硬盘中存储的文件进行管理，在存储空间短缺的情况下，会优先将最近最少使用的文件删除，以扩展可用的硬盘空间。

## 1 支持数据写入硬盘缓存中

前置条件：NA 

场景：
1. 支持数据写入硬盘缓存中
2. 支持从硬盘缓存中读取数据
3. 支持从硬盘缓存中删除指定key值的缓存文件
4. 支持同步缓存文件的操作记录至journal和关闭缓存
约束： NA     
性能： NA    
可靠性： NA 


### 1.1 支持数据写入硬盘缓存中

支持数据写入硬盘缓存中，使用指定的缓存目录

#### 1.1.1 主要接口

```cangjie
public class DiskLruCache {

    /**
     * 打开缓存目录，如果不存在则创建缓存
     * 
     * 参数 directory - 缓存目录
     * 参数 appVersion - 缓存版本
     * 参数 valueCount - 算每个缓存项的值
     * 参数 maxSize - 存储的最大字节数
     * 返回值 DiskLruCache - 返回缓存的对象
     */
    public static func open(directory: Directory, appVersion: Int64, valueCount: Int64, maxSize: Int64): DiskLruCache

    /**
     * 关闭缓存并删除其所有存储的值
     */
    public func delete(): Unit

    /**
     * 关闭缓存
     */
    public func close(): Unit

    /**
     * 返回此缓存存储其数据的目录
     *
     * 返回值 Directory
     */
    public func getDirectory(): Directory

    /**
     * 返回此缓存应用于存储的最大字节数
     *
     * 返回值 Int64
     */
    public func getMaxSize(): Int64

    /**
     * 更改缓存可以存储的最大字节数
     * 
     * 参数 maxSize - 最大字节数
     */
    public func setMaxSize(maxSize: Int64): Unit

    /**
     * 返回当前用于存储中的值的字节数
     *
     * 返回值 Int64
     */
    public func getSize(): Int64

    /**
     * 如果此缓存已关闭，则返回true
     *
     * 返回值 Bool
     */
    public func isClosed(): Bool

    /**
     * 对文件系统执行缓冲操作
     */
    public func flush(): Unit

    **
     * 返回缓存的目录的编辑器
     * 
     * 参数 key - 缓存文件的标记
     * 返回值 Option<Editor>
     */
    public func edit(key: String): Option<Editor>

}
```

#### 1.1.2 示例

```cangjie
from disklrucache import disklrucache.*
from std import io.*
from std import fs.*
from std import os.posix.*
from std import unittest.*
from std import unittest.testmacro.*

main() {

    let lrucache = LruCacheOpen1Test()
    lrucache.open1Test()
    return 0
}

@Test
public class LruCacheOpen1Test {
    @TestCase
    public func open1Test(): Unit {

        var path: String = getcwd()
        var TmpDir = path + "/DiskLruCacheTest"
        let appVersion = 100
        var cacheDir = Directory.create(TmpDir) 
        var cache = DiskLruCache.open(cacheDir, appVersion, 2, Int64(Int32.Max))
        let key = "k1"
        let src = cache.edit(key).getOrThrow()
        src.set(0, "ABC")
        src.set(1, "DE")
        let pc = src.getString(0).isEmpty()
        src.commit()
        println("success")
        @Assert(true, pc)    
    }
}
```
执行结果如下：

```
success
```

## 2 其他接口

### 2.1 Editor

文件的编辑器

```cangjie
public class Editor {

    /**
     * 中止此编辑
     */
    public func abort(): Unit 

    /**
     * 返回一个未缓冲的输入流
     *
     * 参数 index - 缓存标记值
     * 返回值 Option<InputStream>
     */
    public func newInputStream(index: Int64): Option<InputStream>

    /**
     * 以字符串形式返回最后提交的值
     *
     * 参数 index - 缓存标记值
     * 返回值 String
     */
    public func getString(index: Int64): String

    /**
     * 返回一个新的未缓冲的输出流
     *
     * 参数 index - 缓存标记值
     * 返回值 File
     */
    public func newOutputStream(index: Int64): File

    /**
     * 设置缓存的数据
     *
     * 参数 index - 缓存的文件名
     * 参数 value - 缓存的数据
     */
    public func set(index: Int64, value: String): Unit

    /**
     * 提交此编辑的数据
     */
    public func commit(): Unit

    /**
     * 进行终止
     */
    public func abortUnlessCommitted(): Unit 
}
```
