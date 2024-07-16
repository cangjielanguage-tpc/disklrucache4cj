/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */
package disklrucache

import std.io.*
import std.fs.*
import std.collection.*
import charset.*
import charset.encoding.*
class Util {

    static let US_ASCII: Charset = Charsets.ISO_8859_2
    static let UTF_8: Charset = Charsets.UTF8


    static func readFully(ins: StringReader<InputStream>): String {
        var str: String = ins.readToEnd()
        return str
    }

    static func deleteContents(dir: Directory): Unit {
        var files = dir.entryList()
        if (files.isEmpty()) {
            throw DiskLruCacheException("not a readable directory")
        }
        for (fil in files) {
            if (fil.isDirectory()) {
                deleteContents(Directory(fil.path))
            }
            if (fil.isFile()) {
                File.delete(fil.path)
            }
        }
    }

    static func closeQuietly(closeable: Resource) {
        try {
            closeable.close()
        }catch (e: Exception) {
            throw e
        }
    }
}

class ReallBufferSink <: Sink {
    var closed: Bool = false
    var sink: Sink
    private var buf: ByteArrayStream = ByteArrayStream()

    public init(sink: Sink) {
        this.sink = sink

    }

    public func write(bytes: Array<Byte>): Unit {
        if (closed) {
            throw DiskLruCacheException("closed")
        } else {
            buf.write(bytes)
        }
    }

    public func flush(): Unit {
        if (closed) {
            throw DiskLruCacheException("closed");
        } else {
            if (this.buf.length > 0) {
                this.sink.write(this.buf.readToEnd())
            }
            this.sink.flush()
        }
    }


    public func close(): Unit {
        if (!closed) {
            if (buf.length > 0) {
                this.sink.write(this.buf.readToEnd())
            }
            sink.close()
            closed = true
        }
    }
}


public interface Sink {
    func write(bytes: Array<Byte>): Unit
    func flush(): Unit
    func close(): Unit
}

class FileSink <: Sink {

    let file: File

    init (file: File) {
        this.file = file
    }

    public func write(bytes: Array<Byte>): Unit {
        file.write(bytes)
    }

    public func flush(): Unit {
        file.flush()
    }

    public func close(): Unit {
        file.close()
    }
}

