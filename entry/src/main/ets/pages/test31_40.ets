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
struct Test31 {
  @State message: string = 'Hello World';
  appVersion: number = 100
  maxSize: number = 1024 * 1024
  valueCount: number = 2
  directory: string = '/data/storage/el2/base/cache'

  build() {
    Column() {
      Text("对应原库LLT用例 test_open31 到 test_open40 :").width('100%').fontSize(16).textAlign(TextAlign.Start).padding(10)

      Button('test_open31').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, 6, 2147483647)
        let key = "k1"
        let src = cache.edit(key)
        src.set(0, "ABC")
        src.set(1, "DE")
        src.set(2, "FG")
        src.set(3, "HI")
        src.set(4, "HI")
        src.set(5, "HI")
        src.getString(0)
        src.commit()
        let str = cache.getMaxSize()
        console.error("[用例编号]test_open31 ---> [测试结果]：" + (str == 2147483647))
      })

      Button('test_open32').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, 6, this.maxSize)
        let key = "k1"
        let src = cache.edit(key)
        src.set(0, "ABC")
        src.set(1, "DE")
        src.set(2, "FG")
        src.set(3, "HI")
        src.set(4, "HI")
        src.set(5, "HI")
        src.getString(0)
        src.commit()
        cache.setMaxSize(119)
        console.error("[用例编号]test_open32 ---> [测试结果]：" + (cache.getMaxSize() == 119))
      })

      Button('test_open33').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, 6, 123456)
        let key = "k1"
        cache.edit(key)
        console.error("[用例编号]test_open33 ---> [测试结果]：" + (cache.getMaxSize() == 123456))
      })

      Button('test_open34').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, 4, this.maxSize)
        let key = "k1"
        cache.edit(key)
        console.error("[用例编号]test_open34 ---> [测试结果]：" + (cache.getSize() == 0))
      })

      Button('test_open35').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        let key = "k1"
        let src = cache.edit(key)
        src.set(0, "OP")
        src.set(1, "LKll")
        src.commit()
        let sc = cache.get("k1").getInputStream(0)
        let sc1 = cache.get("k1").getInputStream(1)
        console.error("[用例编号]test_open35 ---> [测试结果]1：" + (sc.length == 2))
        console.error("[用例编号]test_open35 ---> [测试结果]2：" + (sc1.length == 4))
      })

      Button('test_open36').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        let key = "k1"
        let src = cache.edit(key)
        src.set(0, "OP")
        src.set(1, "LKll")
        src.commit()
        let sc = cache.get("k1").getString(0)
        let sc1 = cache.get("k1").getString(1)
        console.error("[用例编号]test_open36 ---> [测试结果]1：" + (sc == "OP"))
        console.error("[用例编号]test_open36 ---> [测试结果]2：" + (sc1 == "LKll"))
      })

      Button('test_open37').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        let key = "k1"
        let src = cache.edit(key)
        src.set(0, "OP")
        src.set(1, "LKll")
        src.commit()
        let sc = cache.get("k1").getString(0)
        console.error("[用例编号]test_open37 ---> [测试结果]：" + (sc == "OP"))
      })

      Button('test_open38').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        let key = "k1"
        let src = cache.edit(key)
        src.set(0, "OP")
        src.set(1, "LKll")
        src.commit()
        let sc = cache.get("k1")
        sc.close()
        let ssc = false
        try {
          sc.getString(0)
        } catch (err) {
          ssc = true
        }
        console.error("[用例编号]test_open38 ---> [测试结果]：" + ssc)
      })

      Button('test_open39').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        let key = "k1"
        let src = cache.edit(key)
        src.set(0, "OP")
        src.set(1, "LKll")
        src.commit()
        let sc = cache.get("k1")
        let sc1 = sc.getLength(0)
        console.error("[用例编号]test_open39 ---> [测试结果]：" + (sc1 == 2))
      })

      Button('test_open40').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        let src = cache.isClosed()
        console.error("[用例编号]test_open40 ---> [测试结果]：" + (src == false))
      })
    }
    .height('100%')
    .width('100%')
  }
}