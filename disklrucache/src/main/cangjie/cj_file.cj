/**
 * Created on 2025/6/21
 */
package disklrucache

import ohos.ark_interop.*
import ohos.ark_interop_macro.*
import std.fs.OpenMode
import std.io.SeekPosition
import std.fs.File

@Interop[ArkTS]
public class FileArkTs {
    var file: File

    public prop length: Int64 {
        get() {
            return file.length
        }
    }

    public prop position: Int64 {
        get() {
            return file.position
        }
    }

    public prop remainLength: Int64 {
        get() {
            return file.remainLength
        }
    }

    init(file: File) {
        this.file = file
    }

    public init(path: String, openMode: OpenModeArkTs) {
        this.file = File(path, openMode.openMode)
    }

    public func close(): Unit{
        file.close()
    }

    public func flush(): Unit{
        file.flush()
    }

    public func isClosed(): Bool{
        return file.isClosed()
    }

    public func read(buffer: Array<Byte>): Array<Byte>{
        let res = file.read(buffer)
        return if (res > 0) {
            buffer[0..res].toArray()
        } else {
            Array<Byte>()
        }
    }

    public func seek(sp: SeekPositionArkTs): Int64 {
        file.seek(sp.seekPosition)
    }

    public func write(buffer: Array<Byte>): Unit {
        file.write(buffer)
    }
}

@Interop[ArkTS]
public class OpenModeArkTs {
    var openMode: OpenMode

    init(openMode: OpenMode) {
        this.openMode = openMode
    }

    public init(typ: Int64, read: Bool, write: Bool) {
        match (typ) {
            case 0 => this.openMode = OpenMode.Append
            case 1 => this.openMode = OpenMode.Read
            case 2 => this.openMode = OpenMode.Write
            case 3 => this.openMode = OpenMode.ReadWrite
            case _ => this.openMode = OpenMode.Read
        }
    }
}

@Interop[ArkTS]
public class SeekPositionArkTs {
    var seekPosition: SeekPosition

    init(seekPosition: SeekPosition) {
        this.seekPosition = seekPosition
    }

    public init(typ: Int64, seek: Int64) {
        match (typ) {
            case 0 => this.seekPosition = SeekPosition.Begin(seek)
            case 1 => this.seekPosition = SeekPosition.Current(seek)
            case 2 => this.seekPosition = SeekPosition.End(seek)
            case _ => this.seekPosition = SeekPosition.Begin(seek)
        }
    }
}