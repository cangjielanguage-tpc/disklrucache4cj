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
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Test21 {
  @State message: string = 'Hello World';
  appVersion: number = 100
  maxSize: number = 1024 * 1024
  valueCount: number = 2
  directory: string = '/data/storage/el2/base/cache'

  build() {
    Column() {
      Text("对应原库LLT用例 test_open21 到 test_open30 :").width('100%').fontSize(16).textAlign(TextAlign.Start).padding(10)

      Button('test_open21').width('95%').margin(5).onClick(() => {
        // TODO 需要有本地文件
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        let key = "k1"
        let src = cache.edit(key)
        src.set(0, "ABC")
        src.set(1, "DE")
        let pc = src.getString(0)
        console.error("[用例编号]test_open21 ---> [测试结果]：" + (pc != ""))
      })

      Button('test_open22').width('95%').margin(5).onClick(() => {
        let Illegal = false
        try {
          let cache = new DiskLruCache(this.directory, this.appVersion, -1, this.maxSize)
        } catch (err) {
          Illegal = true
        }
        console.error("[用例编号]test_open22 ---> [测试结果]：" + Illegal)
      })

      Button('test_open23').width('95%').margin(5).onClick(() => {
        let Illegal = false
        try {
          let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, -100)
        } catch (err) {
          Illegal = true
        }
        console.error("[用例编号]test_open23 ---> [测试结果]：" + Illegal)
      })

      Button('test_open24').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, 4, this.maxSize)
        let key = "k1"
        let src = cache.edit(key)
        src.set(0, "ABC")
        src.set(1, "DE")
        src.set(2, "FG")
        src.set(3, "HI")
        let pc = src.getString(0)
        console.error("[用例编号]test_open24 ---> [测试结果]：" + (pc == ""))
        src.commit()
      })

      Button('test_open25').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, 4, this.maxSize)
        let stp = cache.getDirectory()
        console.error("[用例编号]test_open25 ---> [测试结果]：" + (stp == this.directory))
      })

      Button('test_open26').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, 4, 2147483647)
        let stp = cache.getMaxSize()
        console.error("[用例编号]test_open26 ---> [测试结果]：" + (stp == 2147483647))
      })

      Button('test_open27').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, 4, this.maxSize)
        cache.setMaxSize(110)
        let stp = cache.getMaxSize()
        console.error("[用例编号]test_open27 ---> [测试结果]：" + (stp == 110))
      })

      Button('test_open28').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, 4, this.maxSize)
        let key = "k1"
        let src = cache.edit(key)
        src.set(0, "ABC")
        src.set(1, "DE")
        src.set(2, "FG")
        src.set(3, "HI")
        src.getString(0)
        src.commit()
        let str = cache.getSize()
        console.error("[用例编号]test_open28 ---> [测试结果]：" + (str == 9))
      })

      Button('test_open29').width('95%').margin(5).onClick(() => {
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
        let str = cache.getSize()
        console.error("[用例编号]test_open29 ---> [测试结果]：" + (str == 13))
      })

      Button('test_open30').width('95%').margin(5).onClick(() => {
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
        let str = cache.getDirectory()
        console.error("[用例编号]test_open30 ---> [测试结果]：" + (str == this.directory))
      })
    }
    .height('100%')
    .width('100%')
  }
}