<div align="center">
<h1>diskLruCache4cj</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v1.0.0-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/build-pass-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v1.0.1-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjcov----brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/project-open-brightgreen" style="display: inline-block;" />
</p>

## 介绍

DiskLruCache 是一个管理硬盘内容的存储管理工具，它采用了最近最少使用（LRU）算法，以对硬盘中存储的文件进行管理，在存储空间短缺的情况下，会优先将最近最少使用的文件删除，以扩展可用的硬盘空间。
 
### 特性

- 🚀 支持数据写入硬盘缓存中

- 🚀 支持从硬盘缓存中读取数据

- 💪 支持从硬盘缓存中删除指定key值的缓存文件

- 🛠️ 支持同步缓存文件的操作记录至journal和关闭缓存


### 源码目录

```shell
.
├── AppScope
├── doc                      # API文档
│   ├── assets
│   └── feature_api.md
├── disklrucache
│   └── src
│      └─ main
│          ├─ cangjie        # cangjie 源码
│          ├─ ets            # ets 源码                       
│          └─ resources      # 资源文件
├── entry                    # 示例代码文件夹
├── hvigor                   # 构建工具目录
└── README.md                # 介绍及使用说明
```

- `doc`  文档目录，用于存API接口文档
- `disklrucache`  是库源码目录
- `entry` 存放 示例代码

### 接口说明

主要类和函数接口说明详见 [API](./doc/feature_api.md)


## 使用说明

### 编译构建

1. 下载安装: 通过中心仓下载安装

```sh
ohpm install @cangjie-tpc/disklrucache
```

2. 在项目中使用 pinyin 项目

```extendtypescript
import {
  DiskLruCache,
  Snapshot,
  SeekPosition,
  Editor,
  SeekPositionEnum,
  File,
  OpenMode,
  OpenModeEnum
} from '@cangjie-tpc/disklrucache'
```


### 功能示例

从缓存中读取数据 

```extendtypescript
import {
  DiskLruCache,
  Snapshot,
  SeekPosition,
  Editor,
  SeekPositionEnum,
  File,
  OpenMode,
  OpenModeEnum
} from '@cangjie-tpc/disklrucache'

@Entry
@Component
struct Index {
  appVersion: number = 100
  maxSize: number = 1024 * 1024
  valueCount: number = 2
  directory: string = '/data/storage/el2/base/cache'

  build() {
    Column() {
      Button('创建缓存-读取缓存').onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        let key = "k1"
        let editor = cache.edit(key)
        editor.set(0, "OP")
        editor.set(1, "LKll")
        editor.commit()

        let snapShot = cache.get("k1")
        let str0 = snapShot.getString(0)
        let str1 = snapShot.getString(1)
        console.error("---------------> 测试缓存读取str0：" + str0)
        console.error("---------------> 测试缓存读取str1：" + str1)
      })
    }
    .height('100%')
    .width('100%')
  }
}
```

执行结果如下：

```shell
E     ---------------> 测试缓存读取str0：OP
E     ---------------> 测试缓存读取str1：LKll
```

## 开源协议

本项目基于 [Apache License 2.0](./LICENSE) ，请自由的享受和参与开源。

## 参与贡献

欢迎给我们提交PR，欢迎给我们提交Issue，欢迎参与任何形式的贡献。