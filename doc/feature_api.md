# diskLruCache4cj库

## 介绍

DiskLruCache 是一个管理硬盘内容的存储管理工具，它采用了最近最少使用（LRU）算法，以对硬盘中存储的文件进行管理，在存储空间短缺的情况下，会优先将最近最少使用的文件删除，以扩展可用的硬盘空间。


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
     * 异常 DiskLruCacheException 如果maxSize和valueCount为小于等于零时抛出
     * 返回值 DiskLruCache - 返回缓存的对象
     */
    public static func open(directory: Directory, appVersion: Int64, valueCount: Int64, maxSize: Int64): DiskLruCache

    /**
     * 关闭缓存并删除其所有存储的值
     * 异常 DiskLruCacheException 当directory缓存目录不存在时，抛出异常
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
     * 异常 DiskLruCacheException 当 maxSize 小于等于零时，抛出异常
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
     * 异常 DiskLruCacheException 当调用close()方法后使用时，抛出异常
     */
    public func flush(): Unit

    **
     * 返回缓存的目录的编辑器
     * 
     * 参数 key - 缓存文件的标记
     * 返回值 Option<Editor>
     * 异常 DiskLruCacheException 当调用close()方法后使用时,当key不符合正则匹配("[a-z0-9_-]{1,64}")，抛出异常
     */
    public func edit(key: String): Option<Editor>

}
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
public class DiskLruCacheException <: Exception {
    /**
     * 异常初始化
     */
    public init()

    /**
     * 异常初始化
     *
     * 参数 messages - 异常信息
     */
    public init(messages: String)

    /**
     * 获取异常信息
     *
     * 返回值 String - 异常信息
     */
    public func getMessage(): String

    /**
     * 异常信息转换为 String 类型
     *
     * 返回值 String
     */
    public override func toString(): String
}
```

#### 1.1.2 示例

```cangjie
from disklrucache import disklrucache.*
from std import fs.*
from std import math.*
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

### 1.2 支持从硬盘缓存中读取数据

支持从硬盘缓存中读取数据

#### 1.2.1 主要接口

```cangjie
public class DiskLruCache {

    /**
     * 获取缓存的对象
     * 
     * 参数 key - 缓存文件的标记值
     * 返回值 Option<Snapshot> - 读取文件的对象
     */
    public func get(key: String): Option<Snapshot>

}

public class Snapshot {

    /**
     * 获取文件编辑的对象
     *
     * 返回值 Option<Editor> - 读取文件编辑的对象
     */
    public func edit(): Option<Editor>

    /**
     * 返回缓存的文件流
     * 
     * 参数 index - 缓存文件的设置的标记值
     * 返回值 File - 缓存的文件对象
     * 异常 DiskLruCacheException 当调用close()方法后使用时，抛出异常
     */
     public func getInputStream(index: Int64): File

    /**
     * 获取对应缓存的数据
     * 
     * 参数 index - 缓存文件的设置的标记值
     * 返回值 String - 存储的值
     * 异常 DiskLruCacheException 当调用close()方法后使用时，抛出异常
     */
    public func getString(index: Int64): String

    /**
     * 获取缓存数据的长度
     * 
     * 参数 index - 缓存文件的设置的标记值
     * 返回值 Int64 - 缓存数据的长度
     * 异常 IndexOutOfBoundsException 当index不是存储的下标时，抛出异常
     */
    public func getLength(index: Int64): Int64

    /**
     * 关闭缓存文件流
     */
    public func close(): Unit
}
```

#### 1.2.2 示例

```cangjie
from disklrucache import disklrucache.*
from std import fs.*
from std import math.*
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
        var TmpDir = path + "/DiskLruCacheTest37"
        let appVersion = 100
        var cacheDir = Directory.create(TmpDir) 
        var cache = DiskLruCache.open(cacheDir, appVersion, 2, Int64(Int32.Max))
        let key = "k1"
        let src = cache.edit(key).getOrThrow()
        src.set(0, "OP")
        src.set(1, "LKll")
        src.commit()
        let sc = cache.get("k1").getOrThrow().getString(0)
        println("success")
        @Assert("OP", sc)
    }
}
```
执行结果如下：

```
success
```

### 1.3 支持从硬盘缓存中删除指定key值的缓存文件

缓存中删除指定key值的缓存文件

#### 1.3.1 主要接口

```cangjie
public class DiskLruCache {

    /**
     * 删除指定key值的缓存
     * 
     * 参数 key - 缓存文件的标记值
     * 返回值 Bool - 是否删除成功
     * 异常 DiskLruCacheException 当调用close()方法后使用时，抛出异常
     */
    public func remove(key: String): Bool

}
```

#### 1.3.2 示例

```cangjie
from disklrucache import disklrucache.*
from std import fs.*
from std import math.*
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
        src.getString(0).isEmpty()
        src.commit()
        let cq = cache.remove("k1")
        println("success")
        @Assert(true, cq)    
    }
}
```
执行结果如下：

```
success
```

### 1.4 支持同步缓存文件的操作记录至journal和关闭缓存

支持关闭缓存

#### 1.4.1 主要接口

```cangjie
public class DiskLruCache {

    /**
     * 关闭此缓存,存储的值将保留在文件系统中
     */
    public func close(): Unit

}
```

#### 1.4.2 示例

```cangjie
from disklrucache import disklrucache.*
from std import fs.*
from std import math.*
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
        cache.close()
        cache.isClosed()
        println("success")
        @Assert(true, cache.isClosed())

    }
}
```
执行结果如下：

```
success
```
