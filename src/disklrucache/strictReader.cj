/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */
package disklrucache

from std import io.*
from std import fs.*
from std import sync.*
from std import collection.*
from charset import charset.*
from charset import  charset.encoding.*

class StrictLineReader {

    private static let CR = UInt8(UInt32('\r'))
    private static let LF = UInt8(UInt32('\n'))

    private var input: InputStream

    private var charset: Charset

    private var buf: Array<Byte>
    private var pos: Int64 = 0
    private var end: Int64 = 0
    
    private let lock: Monitor = Monitor()

    public init(input: InputStream, charset: Charset) {
        this(input, 8192, charset)
    }

    public init(input: InputStream, capacity: Int64, charset: Charset) {
        if (capacity <  0) {
            throw DiskLruCacheException("the capacity of strictLineReader cannot be negative")
        }
        if (!(charset.nameEquals("ISO-8859-2"))) {
            throw DiskLruCacheException("unsupported encoding")
        }
        this.input = input
        this.charset = charset
        this.buf = Array<Byte>(capacity, item:0)
    }

    public func readLine(): String {
        synchronized (lock) {
            if (buf.isEmpty()) {
                throw DiskLruCacheException("lineReader is closed")
            }

            if (pos >= end) {
                fillBuf()
            }

            for (i in pos..end) {
                if (buf[i] == LF) {
                    var lineEnd = -1
                    if (i != pos && buf[i - 1] == CR) {
                        lineEnd = i-1
                    }else {
                        lineEnd = i
                    }
                    let res = unsafe { String.fromUtf8Unchecked(buf.slice(pos,lineEnd -pos)) }
                    pos = i + 1
                    return res
                }
            }

            var out: ByteArrayStream = ByteArrayStream(end - pos + 80)

            while (true) {
                out.write(buf.slice(pos,end -pos))
                end = -1
                fillBuf()
                for (i in pos..end) {
                    if (buf[i] == LF) {
                        if (i != pos) {
                            out.write(buf.slice(pos,i -pos))
                        }
                        pos = i+1
                        var bytes: Array<Byte> = out.bytes()
                        return bytes.toString()
                    }
                }
            }
            return ""
        }
        
    }

    private func fillBuf(): Unit {
        let resu = this.input.read(buf)
        if (resu == 0) {
            throw DiskLruCacheException("no data readable")
        }
        this.pos = 0
        this.end = resu
    }

    protected func close(): Unit {
        (this.input as Resource)?.close()
    }
}

