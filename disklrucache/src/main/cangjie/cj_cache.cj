/**
 * Created on 2025/8/19
 */
package disklrucache

import ohos.ark_interop.*
import ohos.ark_interop_macro.*

import disklrucache.core.DiskLruCache

import std.fs.Path
import ohos.hilog.Hilog
import disklrucache.core.DiskLruCacheException

@Interop[ArkTS]
public class DiskLruCacheArkTs {

    var cache: DiskLruCache

    public init(directory: String, appVersion: Int64, valueCount: Int64, maxSize: Int64) {
        var path: Path = Path(directory)
        try {
            cache = DiskLruCache.open(path, appVersion, valueCount, maxSize)
        } catch (e: DiskLruCacheException) {
            // 异常处理
            Hilog.error(0x000000, "DiskLruCache", e.getMessage())
            throw Exception(e.getMessage())
        }
    }

    public func edit(key: String, diskLruCacheArkTs: DiskLruCacheArkTs): EditorArkTs {
        return EditorArkTs(key, -1, diskLruCacheArkTs)
    }

    public func get(key: String, diskLruCacheArkTs: DiskLruCacheArkTs): SnapshotArkTs {
        return SnapshotArkTs(key, diskLruCacheArkTs)
    }

    public func delete(): Unit {
        try {
            cache.delete()
        } catch (e: DiskLruCacheException) {
            // 异常处理
            Hilog.error(0x000000, "DiskLruCache", e.getMessage())
        }
    }

    public func close(): Unit{
        try {
            cache.close()
        } catch (e: DiskLruCacheException) {
            // 异常处理
            Hilog.error(0x000000, "DiskLruCache", e.getMessage())
        }
    }

    public func remove(key: String): Bool {
        try {
            cache.remove(key)
        } catch (e: DiskLruCacheException) {
            // 异常处理
            Hilog.error(0x000000, "DiskLruCache", e.getMessage())
            return false
        }
    }

    public func getDirectory(): String {
        return cache.getDirectory().toString()
    }

    public func getMaxSize(): Int64 {
        return cache.getMaxSize()
    }

    public func setMaxSize(maxSize: Int64): Unit {
        try {
            cache.setMaxSize(maxSize)
        } catch (e: DiskLruCacheException) {
            // 异常处理
            Hilog.error(0x000000, "DiskLruCache", e.getMessage())
        }
    }

    public func getSize(): Int64 {
        return cache.getSize()
    }

    public func isClosed(): Bool {
        cache.isClosed()
    }

    public func flush(): Unit {
        try {
            cache.flush()
        } catch (e: DiskLruCacheException) {
            // 异常处理
            Hilog.error(0x000000, "DiskLruCache", e.getMessage())
        }
    }
}