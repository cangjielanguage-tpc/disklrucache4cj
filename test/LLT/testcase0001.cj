// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import disklrucache.*
import std.io.*
main() {
    var str = BlSink()
    let data: Array<Byte> = [0,1]
    str.write(data)
    if (str.buf.length != 2) {
        return 1
    }
    return 0
}

public class BlSink <: Sink {
    public var buf: ByteBuffer  = ByteBuffer ()
    public init () {}
    public func write(bytes: Array<Byte>): Unit {
        buf.write(bytes)
    }

    public func flush(): Unit {}

    public func close(): Unit {}
}

