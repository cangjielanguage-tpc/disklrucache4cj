/**
 * Created on 2025/8/19
 */
package disklrucache

import ohos.ark_interop.*
import ohos.ark_interop_macro.*

import disklrucache.core.Editor
import ohos.hilog.Hilog
import std.fs.FileInfo
import std.fs.Path
import disklrucache.core.DiskLruCacheException

@Interop[ArkTS]
public class EditorArkTs {

    var editor: Option<Editor>

    public init(key: String, expectedSequenceNumber: Int64, cacheArkTs: DiskLruCacheArkTs) {
        editor = cacheArkTs.cache.edit(key, expectedSequenceNumber)
    }

    public func abort(): Unit {
        editor?.abort()
    }

    public func getString(index: Int64): String {
        if (let Some(ed) <- editor) {
            ed.getString(index)
        } else {
        	""
        }
    }

    public func set(index: Int64, value: String): Unit {
        editor?.set(index, value)
    }

    public func commit(): Unit {
        try {
            editor?.commit()
        } catch (e: DiskLruCacheException) {
            // 异常处理
            Hilog.error(0x000000, "DiskLruCache", e.getMessage())
        } catch (e: Exception) {
            Hilog.error(0x000000, "Exception", e.message)
        }
    }

    public func abortUnlessCommitted(): Unit {
        editor?.abortUnlessCommitted()
    }

    // 原返回值为 Option<InputStream>
    // 这个方法从源码中看，没有后续的操作，要使用只能是自己加上封装，再转成byte数组或者String
    // 所以不再加其他的互操作封装，直接把获取到的String转成Array<Byte>返回
    public func newInputStream(index: Int64): Array<Byte> {
        try {
            var byteString = editor?.getString(index) ?? ""
            return byteString.toArray()
        } catch (e: DiskLruCacheException) {
            // 异常处理
            Hilog.error(0x000000, "DiskLruCache", e.getMessage())
            return Array<Byte>()
        }
    }

    // 改成返回文件完整路径
    public func newOutputStream(index: Int64): String {
        try {
            var path = editor?.newOutputStream(index).info.path
            if (let Some(p) <- path) {
                return p.toString()
            } else {
                return ""
            }
        } catch (e: DiskLruCacheException) {
            // 异常处理
            Hilog.error(0x000000, "DiskLruCache", e.getMessage())
            return ""
        }

    }
}