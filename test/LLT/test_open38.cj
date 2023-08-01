// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from disklrucache import disklrucache.*
from std import io.*
from std import fs.*
from std import os.posix.*
from std import unittest.*
from std import unittest.testmacro.*
from std import math.*
main() {

    let lrucache = LruCacheOpen1Test()
    lrucache.open1Test()
    return 0
}

@Test
public class LruCacheOpen1Test {
    @TestCase
    public func open1Test(): Unit {

        var path: String = getcwd()
        var TmpDir = path + "/DiskLruCacheTest38"
        let appVersion = 100
        var cacheDir = Directory.create(TmpDir) 
        var cache = DiskLruCache.open(cacheDir, appVersion, 2, Int64(Int32.Max))
        let key = "k1"
        let src = cache.edit(key).getOrThrow()
        src.set(0, "OP")
        src.set(1, "LKll")
        src.commit()
        let sc = cache.get("k1").getOrThrow()
        sc.close()
        var ssc = false 
        try {
            sc.getString(0)
        }catch (e: Exception) {
            ssc = true
        }
        
        @Assert(true, ssc)
    }
}

