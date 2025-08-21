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
struct Test01 {
  @State message: string = 'Hello World';
  appVersion: number = 100
  maxSize: number = 1024 * 1024
  valueCount: number = 2
  directory: string = '/data/storage/el2/base/cache'

  build() {
    Column() {
      Text("对应原库LLT用例 test_open01 到 test_open10 :").width('100%').fontSize(16).textAlign(TextAlign.Start).padding(10)

      Button('test_open01').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, 2147483647)
        console.error("[用例编号]test_open01 ---> [测试结果]：" + (cache.getMaxSize() == 2147483647))
      })

      Button('test_open02').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        let key = "0123456789012345678901234567890123456789012345678901234567890123"
        cache.edit(key).abort()
        console.error("[用例编号]test_open02 ---> [测试结果]：" + (cache.getDirectory() == this.directory))
      })

      Button('test_open03').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        let src = cache.isClosed()
        console.error("[用例编号]test_open03 ---> [测试结果]：" + (src == false))
      })

      Button('test_open04').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        cache.close()
        console.error("[用例编号]test_open04 ---> [测试结果]：" + cache.isClosed())
      })

      Button('test_open05').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        cache.delete()
        console.error("[用例编号]test_open05 ---> [测试结果]：" + cache.isClosed())
      })

      Button('test_open06').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        console.error("[用例编号]test_open06 ---> [测试结果]：" + (cache.getSize() == 0))
      })

      Button('test_open07').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        cache.flush()
        console.error("[用例编号]test_open07 ---> [测试结果]：" + (cache.isClosed() == false))
      })

      Button('test_open08').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        cache.setMaxSize(10086)
        console.error("[用例编号]test_open08 ---> [测试结果]：" + (cache.getMaxSize() == 10086))
      })

      Button('test_open09').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        let key = "0123456789012345678901234567890123456789012345678901234567890123"
        cache.edit(key).abortUnlessCommitted()
        console.error("[用例编号]test_open09 ---> [测试结果]：" + (cache.getDirectory() == this.directory))
      })

      Button('test_open10').width('95%').margin(5).onClick(() => {
        let cache = new DiskLruCache(this.directory, this.appVersion, this.valueCount, this.maxSize)
        let key = "0123456789012345678901234567890123456789012345678901234567890123"
        cache.edit(key).commit()
        console.error("[用例编号]test_open10 ---> [测试结果]：查看日志打印内容包含：newly created entry didn't create value for index 0")
      })

    }
    .height('100%')
    .width('100%')
  }
}