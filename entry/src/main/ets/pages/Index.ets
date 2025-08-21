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
import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Column() {
      Button('测试用例01-10').width('95%').margin(5).onClick(() => {
        router.pushUrl({ url: 'pages/test01_10' })
      })

      Button('测试用例11-20').width('95%').margin(5).onClick(() => {
        router.pushUrl({ url: 'pages/test11_20' })
      })

      Button('测试用例21-30').width('95%').margin(5).onClick(() => {
        router.pushUrl({ url: 'pages/test21_30' })
      })

      Button('测试用例31-40').width('95%').margin(5).onClick(() => {
        router.pushUrl({ url: 'pages/test31_40' })
      })

      Button('测试用例41-51').width('95%').margin(5).onClick(() => {
        router.pushUrl({ url: 'pages/test41_51' })
      })
    }
    .height('100%')
    .width('100%')
  }
}