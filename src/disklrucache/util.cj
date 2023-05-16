package disklrucache

from std import io.*
from std import fs.*
from std import collection.*
from charset import charset.*
from charset import  charset.encoding.*
class Util {

    static let US_ASCII: Charset = Charsets.ISO_8859_2
    static let UTF_8: Charset = Charsets.UTF8


    static func readFully(ins: StringReader): String {
        var str: String = ins.readToEnd()
        return str
    }

    static func deleteContents(dir: Directory): Unit {
        var files = dir.entryList()
        if (files.isEmpty()) {
            throw Exception("not a readable directory")
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
            throw Exception("closed")
        } else {
            buf.write(bytes)
        }
    }

    public func flush(): Unit {
        if (closed) {
            throw Exception("closed");
        } else {
            if (this.buf.length > 0) {
                this.sink.write(this.buf.readToEnd())
            }
            this.sink.flush()
        }
    }

    func getBuffer(): ByteArrayStream {
        return buf
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

