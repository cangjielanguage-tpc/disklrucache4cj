//3rd_party_lib:disklrucache4cj/build/disklrucache
//3rd_party_lib:disklrucache4cj/build/charset

from disklrucache import disklrucache.*
from std import io.*
from std import fs.*
from std import os.posix.*
from std import unittest.*
from std import unittest.testmacro.*

@Test
public class disklrucache_Snapshot_edit_001 {
    @TestCase
    public func disklrucache_Snapshot_edit_001(): Unit {

        var path: String = getcwd()
        var TmpDir = path + "/disklrucache_Snapshot_edit_001"
        let appVersion = 100
        var cacheDir = Directory.create(TmpDir)
        var cache = DiskLruCache.open(cacheDir, appVersion, 2, Int64(Int32.Max))

        let key = "k1"
        let src = cache.edit(key).getOrThrow()
        src.set(0, "OP")
        src.set(1, "LKll")
        src.commit()
        let sc = cache.get("k1").getOrThrow().edit().getOrThrow()

        @Assert(sc is Editor, true)
    }
}

