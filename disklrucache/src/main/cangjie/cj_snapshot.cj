/**
 * Created on 2025/8/19
 */
package disklrucache

import ohos.ark_interop.*
import ohos.ark_interop_macro.*

import disklrucache.core.Snapshot
import disklrucache.core.DiskLruCacheException
import ohos.hilog.Hilog

@Interop[ArkTS]
public class SnapshotArkTs {
    var snapshot: Option<Snapshot>
    private var cacheArkTs: DiskLruCacheArkTs
    private var key: String
    private var sequenceNumber: Int64

    public init(key: String, cacheArkTs: DiskLruCacheArkTs) {
    	snapshot = cacheArkTs.cache.get(key)
        sequenceNumber = snapshot?.getSequenceNumber() ?? -1
        this.cacheArkTs = cacheArkTs
        this.key = key
    }

    public func edit(): EditorArkTs {
        return EditorArkTs(key, sequenceNumber, cacheArkTs)
    }

    public func getString(index: Int64): String {
        if (let Some(sn) <- snapshot) {
            sn.getString(index)
        } else {
        	""
        }
    }

    public func getLength(index: Int64): Int64 {
        return snapshot?.getLength(index) ?? 0
    }

    public func close(): Unit {
        snapshot?.close()
    }

    public func getSequenceNumber(): Int64 {
        snapshot?.getSequenceNumber() ?? -1
    }

    // 改成返回文件完整路径
    public func getInputStream(index: Int64): String {
        try {
            var path = snapshot?.getInputStream(index).info.path
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