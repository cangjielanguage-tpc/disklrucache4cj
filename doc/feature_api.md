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


### 1.1 主要接口
```extendtypescript
export class DiskLruCache {
    /**
    * 创建缓存目录
    * 
    * 参数 directory - 缓存目录路径
    * 参数 appVersion - 缓存版本
    * 参数 valueCount - 算每个缓存项的值
    * 参数 maxSize - 存储的最大字节数
    * 异常 DiskLruCacheException 如果maxSize和valueCount为小于等于零时抛出
    * 返回值 DiskLruCache - 返回缓存的对象
    */
    constructor(directory: string, appVersion: number, valueCount: number, maxSize: number)
    
    /**
     * 返回缓存的目录的编辑器
     * 
     * 参数 key - 缓存文件的标记
     * 返回值 Editor
     * 异常 DiskLruCacheException 当调用close()方法后使用时,当key不符合正则匹配("[a-z0-9_-]{1,64}")，抛出异常
     */
    edit(key: string): Editor 
    
    /**
     * 获取缓存的对象
     * 
     * 参数 key - 缓存文件的标记值
     * 返回值 Option<Snapshot> - 读取文件的对象
     */
    get(key: string): Snapshot 
  
    /**
     * 关闭缓存并删除其所有存储的值
     * 异常 DiskLruCacheException 当directory缓存目录不存在时，抛出异常
     */
    delete(): void 
    
    /**
     * 关闭缓存
     */
    close(): void 
    
    /**
     * 删除指定key值的缓存
     * 
     * 参数 key - 缓存文件的标记值
     * 返回值 Bool - 是否删除成功
     * 异常 DiskLruCacheException 当调用close()方法后使用时，抛出异常
     */
    remove(key: string): boolean 
    
    /**
     * 返回此缓存存储其数据的目录路径
     *
     * 返回值 string (cangjie返回值为Directory类型)
     */
    getDirectory(): string 
    
    /**
     * 返回此缓存应用于存储的最大字节数
     *
     * 返回值 number
     */
    getMaxSize(): number 
    
    /**
     * 更改缓存可以存储的最大字节数
     * 
     * 参数 maxSize - 最大字节数
     * 异常 DiskLruCacheException 当 maxSize 小于等于零时，抛出异常
     */
    setMaxSize(maxSize: number): void 
    
    /**
     * 返回当前用于存储中的值的字节数
     *
     * 返回值 number
     */
    getSize(): number 
    
    /**
     * 如果此缓存已关闭，则返回true
     *
     * 返回值 boolean
     */
    isClosed(): boolean 
    
    
    /**
     * 对文件系统执行缓冲操作
     * 异常 DiskLruCacheException 当调用close()方法后使用时，抛出异常
     */
    flush(): void 
}
```

```extendtypescript
export class Editor {
  /**
   * 中止此编辑
   */
  abort(): void

  /**
   * 以字符串形式返回最后提交的值
   *
   * 参数 index - 缓存标记值
   * 返回值 String
   */
  getString(index: number): string

  /**
   * 设置缓存的数据
   *
   * 参数 index - 缓存的文件名
   * 参数 value - 缓存的数据
   */
  set(index: number, value: string): void
  
  /**
   * 提交此编辑的数据
   */
  commit(): void

  /**
   * 进行终止
   */
  abortUnlessCommitted(): void 
  
  /**
   * 返回一个未缓冲的输入流
   *
   * 参数 index - 缓存标记值
   * 返回值 ArrayBuffer 原返回值为 Option<InputStream>
   */
  newInputStream(index: number): ArrayBuffer
  
  /**
   * 返回一个新的未缓冲的输出流
   *
   * 参数 index - 缓存标记值
   * 返回值 File
   */
  newOutputStream(index: number): File 
}
```

```extendtypescript
export class Snapshot {
  /**
   * 获取文件编辑的对象
   *
   * 返回值 Editor - 读取文件编辑的对象
   */
  edit(): Editor

  /**
   * 获取对应缓存的数据
   *
   * 参数 index - 缓存文件的设置的标记值
   * 返回值 String - 存储的值
   */
  getString(index: number): string

  /**
   * 获取缓存数据的长度
   *
   * 参数 index - 缓存文件的设置的标记值
   * 返回值 Int64 - 缓存数据的长度
   */
  getLength(index: number): number

  /**
   * 关闭缓存文件流
   */
  close(): void
  
  /**
   * 返回缓存的文件流
   *
   * 参数 index - 缓存文件的设置的标记值
   * 返回值 File - 缓存的文件对象
   */
  getInputStream(index: number): File
}
```


### 1.2 示例

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