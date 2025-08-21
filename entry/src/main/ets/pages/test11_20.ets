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
struct Test11 {
  @State message: string = 'Hello World';
  appVersion: number = 100
  maxSize: number = 1024 * 1024
  valueCount: number = 2
  directory: string = '/data/storage/el2/base/cache'

  build() {
    Column() {
      Text("对应原库LLT用例 test_open11 到 test_open20 :").width('100%').fontSize(16).textAlign(TextAlign.Start).padding(10)

      Button('test_open11').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        let key = "0123456789012345678901234567890123456789012345678901234567890123";
        let src = cache.edit(key)
        let buffer = src.newInputStream(1)
        console.error("[用例编号]test_open11 ---> [测试结果]：" + (buffer.byteLength == 0))
      })

      Button('test_open12').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        let key = "0123456789012345678901234567890123456789012345678901234567890123";
        let src = cache.edit(key)
        src.set(0,"1")
        src.set(1,"42")
        let str3 = src.getString(0)
        console.error("[用例编号]test_open12 ---> [测试结果]：" + (str3 == ""))
      })

      Button('test_open13').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        let key = "0123456789012345678901234567890123456789012345678901234567890123";
        let src = cache.edit(key)
        let src1 = src.newOutputStream(1)
        console.error("[用例编号]test_open13 ---> [测试结果]：" + (src1.length == 0))
      })

      Button('test_open14').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        let key = "0123456789012345678901234567890123456789012345678901234567890123";
        let src = cache.edit(key)
        src.abort()
        src.commit()
        console.error("[用例编号]test_open14 ---> [测试结果]：true")
      })

      Button('test_open15').width('95%').margin(5).onClick(() => {
        // TODO 需要本地先有一个journal文件
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        let key = "k1"
        let src = cache.edit(key)
        src.set(0, "ABC")
        src.set(0, "DE")
        let pc = src.getString(0)
        console.error("[用例编号]test_open15 ---> [测试结果]：" + (pc == ""))
      })

      Button('test_open16').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        let key = "k1"
        let src = cache.edit(key)
        src.set(0, "ABC")
        src.set(1, "DE")
        let pc = src.getString(0)
        console.error("[用例编号]test_open16 ---> [测试结果]：" + (pc == ""))
        src.commit()
      })

      Button('test_open17').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        let key = "k1"
        let src = cache.edit(key)
        src.set(0, "ABC")
        src.set(1, "DE")
        let pc = src.getString(0)
        console.error("[用例编号]test_open17 ---> [测试结果]：" + (pc != ""))
        src.commit()
      })

      Button('test_open18').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        let key = "k1"
        let src = cache.edit(key)
        src.set(0, "ABC")
        src.set(1, "DE")
        let pc = src.getString(0)
        console.error("[用例编号]test_open18 ---> [测试结果]：" + (pc != ""))
        src.commit()
        cache.remove("k1")
      })

      Button('test_open19').width('95%').margin(5).onClick(() => {
        // TODO 需要有本地文件
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        let key = "k1"
        let src = cache.edit(key)
        src.set(0, "ABC")
        src.set(1, "DE")
        let pc = src.getString(0)
        console.error("[用例编号]test_open19 ---> [测试结果]：" + (pc != ""))
        src.commit()
      })

      Button('test_open20').width('95%').margin(5).onClick(() => {
        // TODO 需要有本地文件
        let cache = new DiskLruCache(this.directory, 10, this.valueCount, this.maxSize)
        let key = "k1"
        let src = cache.edit(key)
        src.set(0, "ABC")
        src.set(1, "DE")
        let pc = src.getString(0)
        console.error("[用例编号]test_open20 ---> [测试结果]：" + (pc == ""))
      })
    }
    .height('100%')
    .width('100%')
  }
}