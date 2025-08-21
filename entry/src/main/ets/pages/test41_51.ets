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
struct Test41 {
  @State message: string = 'Hello World';
  appVersion: number = 100
  maxSize: number = 1024 * 1024
  valueCount: number = 2
  directory: string = '/data/storage/el2/base/cache'

  build() {
    Column() {
      Text("对应原库LLT用例 test_open41 到 test_open51 :").width('100%').fontSize(16).textAlign(TextAlign.Start).padding(10)

      Button('test_open41').width('95%').margin(5).onClick(() => {
        // TODO 要准备一个journal文件
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        // let filepath = Path(path + "/DiskLruCacheTest41/journal")
        // println(filepath)
        // var lec = File(filepath, ReadWrite)
        // let buf: Array<Byte> = [1,0]
        // lec.write(buf)
        // var cache = DiskLruCache.open(TmpDir, appVersion, 2, Int64(Int32.Max))
        // cache.close()
        // let sc = cache.isClosed()
        // console.error("[用例编号]test_open41 ---> [测试结果]：" + (src == false))
      })

      Button('test_open42').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        let key = "k1"
        let src = cache.edit(key)
        src.set(0, "OP")
        src.set(1, "LKll")
        src.commit()
        cache.close()
        let sc = cache.isClosed()
        console.error("[用例编号]test_open42 ---> [测试结果]：" + sc)
      })

      Button('test_open43').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        let key = "k1"
        let src = cache.edit(key)
        src.set(0, "OP")
        src.set(1, "LKll")
        src.commit()
        cache.remove(key)
        let sc = cache.isClosed()
        console.error("[用例编号]test_open43 ---> [测试结果]：" + (sc == false))
      })

      Button('test_open44').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, 6, 1)
        let sc = cache.getMaxSize()
        console.error("[用例编号]test_open44 ---> [测试结果]：" + (sc == 1))
      })

      Button('test_open45').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, 10, 10)
        let sc = cache.getMaxSize()
        console.error("[用例编号]test_open45 ---> [测试结果]：" + (sc == 10))
      })

      Button('test_open46').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, 2147483647)
        let key = "k1"
        let src = cache.edit(key)
        src.set(0, "ABC")
        src.set(1, "DE")
        src.commit()
        let sc = cache.getMaxSize()
        console.error("[用例编号]test_open46 ---> [测试结果]：" + (sc == 2147483647))
      })

      Button('test_open47').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, 1)
        let key = "k1"
        let src = cache.edit(key)
        src.set(0, "ABC")
        src.set(1, "DE")
        src.commit()
        let sc = cache.getMaxSize()
        console.error("[用例编号]test_open47 ---> [测试结果]：" + (sc == 1))
      })

      Button('test_open48').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, 1)
        let n = 1000 //循环次数多的话要开线程测试
        let see = -1
        for (let i=0; i<n; i++) {
          let src = cache.edit("k1")
          src.set(0, "ABC")
          src.set(1, "DE")
          src.commit()
          see=i
        }
        cache.remove("k1")
        let sc = cache.getMaxSize()
        console.error("[用例编号]test_open48 ---> [测试结果]：" + (sc == 1))
      })

      Button('test_open49').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, 1)
        let sc = cache.getMaxSize()
        console.error("[用例编号]test_open49 ---> [测试结果]：" + (sc == 1))
      })

      Button('test_open50').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, 10)
        let sc = cache.getMaxSize()
        console.error("[用例编号]test_open50 ---> [测试结果]：" + (sc == 10))
      })

      Button('test_open51').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, 10)
        let sc = cache.getMaxSize()
        cache.remove("k1")
        console.error("[用例编号]test_open51 ---> [测试结果]：" + (sc == 10))
      })
    }
    .height('100%')
    .width('100%')
  }
}






// Button('创建缓存-写入缓存').onClick(() => {
//   let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
//   let key = "0123456789012345678901234567890123456789012345678901234567890123"
//   let editor = cache.edit(key)
//   editor.set(0, "str00000000000000000")
//   editor.set(1, "str11111111111111111")
//
//   let str0 = editor.getString(0)
//   let str1 = editor.getString(1)
//
//   console.error("---------------> 测试缓存写入，空是正确的：" + str0)
//   console.error("---------------> 测试缓存写入，空是正确的：" + str1)
// })
//
// Button('创建缓存-读取缓存').onClick(() => {
//   let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
//   let key = "k1"
//   let editor = cache.edit(key)
//   editor.set(0, "OP")
//   editor.set(1, "LKll")
//   editor.commit()
//
//   let snapShot = cache.get("k1")
//   let str0 = snapShot.getString(0)
//   let str1 = snapShot.getString(1)
//   console.error("---------------> 测试缓存读取str0：" + str0)
//   console.error("---------------> 测试缓存读取str1：" + str1)
// })
