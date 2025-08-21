// export {DiskLruCacheArkTs, SnapshotArkTs, EditorArkTs} from 'libdisklrucache.so'

import {
  SnapshotArkTs,
  EditorArkTs,
  DiskLruCacheArkTs,
  FileArkTs,
  OpenModeArkTs,
  SeekPositionArkTs
} from 'libdisklrucache.so'

import { CustomLib } from '../../cangjie/ark_interop_api/ark_interop_api'
import { requireCJLib } from "libark_interop_loader.so"


export class DiskLruCache {
  lib = requireCJLib("libdisklrucache.so") as CustomLib
  diskLruCacheArkTs: DiskLruCacheArkTs

  constructor(directory: string, appVersion: number, valueCount: number, maxSize: number) {
    this.diskLruCacheArkTs = new this.lib.DiskLruCacheArkTs(directory, appVersion, valueCount, maxSize)
  }

  edit(key: string): Editor {
    let editor = new Editor()
    editor.editorArkTs = this.diskLruCacheArkTs.edit(key, this.diskLruCacheArkTs)
    return editor
  }

  get(key: string): Snapshot {
    let snapshot = new Snapshot()
    snapshot.snapshotArkTs = this.diskLruCacheArkTs.get(key, this.diskLruCacheArkTs)
    snapshot.diskLruCacheArkTs = this.diskLruCacheArkTs
    snapshot.key = key
    snapshot.sequenceNumber = snapshot.snapshotArkTs.getSequenceNumber()
    return snapshot
  }

  delete(): void {
    this.diskLruCacheArkTs.delete()
  }

  close(): void {
    this.diskLruCacheArkTs.close()
  }
  
  remove(key: string): boolean {
    return this.diskLruCacheArkTs.remove(key)
  }

  getDirectory(): string {
    return this.diskLruCacheArkTs.getDirectory().toString()
  }

  getMaxSize(): number {
    return this.diskLruCacheArkTs.getMaxSize()
  }

  setMaxSize(maxSize: number): void {
    this.diskLruCacheArkTs.setMaxSize(maxSize)
  }

  getSize(): number {
    return this.diskLruCacheArkTs.getSize()
  }

  isClosed(): boolean {
    return this.diskLruCacheArkTs.isClosed()
  }

  flush(): void {
    this.diskLruCacheArkTs.flush()
  }
}

export class Snapshot {
  lib = requireCJLib("libdisklrucache.so") as CustomLib
  snapshotArkTs: SnapshotArkTs | undefined
  diskLruCacheArkTs: DiskLruCacheArkTs | undefined
  key: string = ""
  sequenceNumber: number = -1

  edit(): Editor {
    let editor = new Editor()
    if (this.diskLruCacheArkTs != undefined) {
      editor.editorArkTs = new EditorArkTs(this.key, this.sequenceNumber, this.diskLruCacheArkTs)
    }
    return editor
  }

  getString(index: number): string {
    if (this.snapshotArkTs != undefined) {
      return this.snapshotArkTs.getString(index)
    } else {
      return ""
    }
  }

  getLength(index: number): number {
    if (this.snapshotArkTs != undefined) {
      return this.snapshotArkTs.getLength(index)
    } else {
      return 0
    }
  }

  close(): void {
    if (this.snapshotArkTs != undefined) {
      this.snapshotArkTs.close()
    }
  }

  getInputStream(index: number): File {
    let openMode = new OpenMode(OpenModeEnum.ReadWrite, true, true)
    if (this.snapshotArkTs != undefined) {
      let path = this.snapshotArkTs.getInputStream(index)
      let file = new File(path, openMode)
      return file
    } else {
      let file = new File("", openMode)
      return file
    }
  }
}

export class Editor {
  lib = requireCJLib("libdisklrucache.so") as CustomLib
  editorArkTs: EditorArkTs | undefined

  abort(): void {
    if (this.editorArkTs != undefined) {
      this.editorArkTs.abort()
    }
  }

  getString(index: number): string {
    if (this.editorArkTs != undefined) {
      return this.editorArkTs.getString(index)
    } else {
      return ""
    }
  }

  set(index: number, value: string): void {
    if (this.editorArkTs != undefined) {
      this.editorArkTs.set(index, value)
    }
  }

  commit(): void {
    if (this.editorArkTs != undefined) {
      this.editorArkTs.commit()
    }
  }

  abortUnlessCommitted(): void {
    if (this.editorArkTs != undefined) {
      this.editorArkTs.abortUnlessCommitted()
    }
  }

  // 原返回值为 Option<InputStream>
  newInputStream(index: number): ArrayBuffer {
    if (this.editorArkTs != undefined) {
      return this.editorArkTs.newInputStream(index)
    } else {
      return new ArrayBuffer(0)
    }
  }

  newOutputStream(index: number): File {
    let openMode = new OpenMode(OpenModeEnum.ReadWrite, true, true)
    if (this.editorArkTs != undefined) {
      let path = this.editorArkTs.newOutputStream(index)
      let file = new File(path, openMode)
      return file
    } else {
      let file = new File("", openMode)
      return file
    }
  }
}

export class File {
  lib = requireCJLib("libdisklrucache.so") as CustomLib
  fileArkTs: FileArkTs
  public length: number
  public position: number
  public remainLength: number

  constructor(path: string, openMode: OpenMode) {
    this.fileArkTs = new this.lib.FileArkTs(path, openMode.openModeArkTs)
    this.length = this.fileArkTs.length
    this.position = this.fileArkTs.position
    this.remainLength = this.fileArkTs.remainLength
  }

  close(): void {
    this.fileArkTs.close()
  }

  flush(): void {
    this.fileArkTs.flush()
  }

  isClosed(): boolean {
    return this.fileArkTs.isClosed()
  }

  read(buffer: ArrayBuffer): ArrayBuffer {
    return this.fileArkTs.read(buffer)
  }

  seek(sp: SeekPosition): number {
    return this.fileArkTs.seek(sp.seekPositionArkTs)
  }

  write(buffer: ArrayBuffer): void {
    return this.fileArkTs.write(buffer)
  }
}

export class SeekPosition {
  lib = requireCJLib("libdisklrucache.so") as CustomLib
  seekPositionArkTs: SeekPositionArkTs

  constructor(typ: SeekPositionEnum, seek: number) {
    let num: number = 0
    switch (typ) {
      case SeekPositionEnum.Begin:
        num = 0
        break
      case SeekPositionEnum.Current:
        num = 1
        break
      case SeekPositionEnum.End:
        num = 2
        break
    }
    this.seekPositionArkTs = new this.lib.SeekPositionArkTs(num, seek)
  }
}

export enum SeekPositionEnum {
  Begin,
  Current,
  End
}

export class OpenMode {
  lib = requireCJLib("libdisklrucache.so") as CustomLib
  openModeArkTs: OpenModeArkTs

  constructor(typ: OpenModeEnum, read: boolean, write: boolean) {
    let num: number = 0
    switch (typ) {
      case OpenModeEnum.Append:
        num = 0
        break
      case OpenModeEnum.Read:
        num = 1
        break
      case OpenModeEnum.Write:
        num = 2
        break
      case OpenModeEnum.ReadWrite:
        num = 3
        break
    }
    this.openModeArkTs = new this.lib.OpenModeArkTs(num, read, write)
  }
}

export enum OpenModeEnum {
  Append,
  Read,
  Write,
  ReadWrite
}