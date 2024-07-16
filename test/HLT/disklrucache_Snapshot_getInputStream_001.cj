//3rd_party_lib:disklrucache4cj/target/release/disklrucache
//3rd_party_lib:disklrucache4cj/target/release/charset

import disklrucache.*
import std.io.*
import std.fs.*
import std.os.posix.*
import std.unittest.*
import std.unittest.testmacro.*
import std.math.*
@Test
public class disklrucache_Snapshot_getInputStream_001 {
    @TestCase
    public func disklrucache_Snapshot_getInputStream_001(): Unit {

        var path: String = getcwd()
        var TmpDir = path + "/disklrucache_Snapshot_getInputStream_001"
        let appVersion = 100
        var cacheDir = Directory.create(TmpDir)
        var cache = DiskLruCache.open(cacheDir, appVersion, 2, Int64(Int32.Max))

        let key = "k1"
        let src = cache.edit(key).getOrThrow()
        src.set(0, "OP")
        src.set(1, "LKll")
        src.commit()
        let file = cache.get("k1").getOrThrow().getInputStream(0)

        println("file.info.path :${file.info.path}")
        @Assert(Path(path).join("disklrucache_Snapshot_getInputStream_001").join("k1.0").toString().replace("/","\\"), file.info.path.toString().replace("/","\\"))
    }
}

