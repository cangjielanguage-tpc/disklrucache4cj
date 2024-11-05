<div align="center">
<h1>diskLruCache4cj</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v0.0.1-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/build-pass-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v0.56.4-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjcov-90.3%25-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/project-open-brightgreen" style="display: inline-block;" />
</p>

## 介绍

DiskLruCache 是一个管理硬盘内容的存储管理工具，它采用了最近最少使用（LRU）算法，以对硬盘中存储的文件进行管理，在存储空间短缺的情况下，会优先将最近最少使用的文件删除，以扩展可用的硬盘空间。
 
### 特性

- 🚀 支持数据写入硬盘缓存中

- 🚀 支持从硬盘缓存中读取数据

- 💪 支持从硬盘缓存中删除指定key值的缓存文件

- 🛠️ 支持同步缓存文件的操作记录至journal和关闭缓存


## 软件架构

### 架构图

<p align="center">
<img src="./doc/assets/readme_framework.png" width="60%" >
</p>


### 源码目录

```shell
.
├── README.md
├── doc
│   ├── assets
│   └── feature_api.md
├── src
│   └── disklrucache
├── test
│    ├── HLT
│    └── LLT
├── CHANGELOG.md
├── gitee_gate.cfg
├── LICENSE.txt
├── module.json
├── README.md
└── README.OpenSource
```

- `doc`  文档目录，用于存API接口文档
- `src`  是库源码目录
- `test` 存放 HLT 测试用例、LLT 自测用例

### 接口说明

主要类和函数接口说明详见 [API](./doc/feature_api.md)


## 使用说明

### 编译构建

#### 1. disklrucache4cj 目录下进行编译

```shell
cjpm update
cjpm build
```

### 执行用例
编译用例并执行，步骤如下：

#### 1. 进入 disklrucache4cj/test/ 目录下创建 tmp 文件夹，然后编译测试用例
```shell
cd disklrucache4cj/test/
mkdir tmp
cjc -O2 --import-path xxxxx/disklrucache4cj/target/release  -L xxxxx/disklrucache4cj/target/release/disklrucache -L xxxxx/disklrucache4cj/target/release/charset -l charset_charset.singlebyte -l charset_charset.korean -l charset_charset.traditionchinese -l charset_charset -l disklrucache_disklrucache -l charset_charset.unicode -l charset_charset.simplechinese -l charset_charset.encoding -l charset_charset.exception -l charset_charset.japanese  LLT/test.cj -o tmp/test.cj.out --test
```

##### 1.1 具体说明

- cjc命令, -O2表示开启优化
```shell
cjc -O2
```
- --import-path 导入disklrucache4cj库编译出来的库文件地址, 注意地址最后有"."
- -L 导入库文件的完整路径
- 导入多个库,每个库都需要--import-path和 -L

```shell
--import-path xxxxx/disklrucache4cj/target/release -L xxxxx/disklrucache4cj/target/release/disklrucache -L xxxxx/disklrucache4cj/target/release/charset
```
- -l 要导入的具体的包, 用"库名_包名"
- 导入一个库中有多个包时,用多个 -l
```shell
--import-path xxxxx/disklrucache4cj/target/release -L xxxxx/disklrucache4cj/target/release/disklrucache -L xxxxx/disklrucache4cj/target/release/charset -l charset_charset.singlebyte -l charset_charset.korean -l charset_charset.traditionchinese -l charset_charset -l disklrucache_disklrucache -l charset_charset.unicode -l charset_charset.simplechinese -l charset_charset.encoding -l charset_charset.exception -l charset_charset.japanese
```

- 测试用例的完整路径和用例中引入文件的完整路径
- -o 用例编译后输出的位置和名称, .out结尾, 一般使用"用例名称.out"
- --test 用例编译命令结尾
```shell
xxxxx/disklrucache4cj/test/LLT/test.cj  -o xxxxx/disklrucache4cj/test/tmp/test.cj.out --test
```

#### 2. 把编译好的文件复制到 .out 文件下(disklrucache4cj/test/tmp/) 
- disklrucache4cj/build/disklrucache/、disklrucache4cj/build/charset/ 目录中的文件都复制到 .out 文件位置(disklrucache4cj/test/tmp/ 中)

#### 3. 进入到.out文件位置，执行用例
- 进入到.out文件位置执行用例
```shell
cd xxxxx/disklrucache4cj/test/tmp/
```
- windows系统打开cmd,输入.out文件完整名称即可执行
```shell
test.cj.out
```
- Linux系统使用 ./.out文件完整名称
```shell
./test.cj.out
```

### 功能示例
#### 数据写入硬盘缓存中 功能示例


```cangjie
import disklrucache.*
import std.fs.*
import std.math.*
import std.os.posix.*
import std.unittest.*
import std.unittest.testmacro.*

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

```shell
success
```

#### 从缓存中读取数据 功能示例

```cangjie
import disklrucache.*
import std.fs.*
import std.math.*
import std.os.posix.*
import std.unittest.*
import std.unittest.testmacro.*

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

```shell
success
```

#### 缓存中删除指定key值的缓存文件 功能示例

```cangjie
import disklrucache.*
import std.fs.*
import std.math.*
import std.os.posix.*
import std.unittest.*
import std.unittest.testmacro.*

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

```shell
success
```

#### 同步缓存文件的操作记录至journal和关闭缓存 功能示例

```cangjie
import disklrucache.*
import std.fs.*
import std.math.*
import std.os.posix.*
import std.unittest.*
import std.unittest.testmacro.*

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

```shell
success
```

## 开源协议

本项目基于 [Apache License 2.0](./LICENSE) ，请自由的享受和参与开源。

## 参与贡献

欢迎给我们提交PR，欢迎给我们提交Issue，欢迎参与任何形式的贡献。