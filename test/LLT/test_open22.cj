// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from disklrucache import disklrucache.*
from std import io.*
from std import fs.*
from std import os.posix.*
from std import unittest.*
from std import unittest.testmacro.*
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
        var TmpDir = path + "/DiskLruCacheTest03"
        let appVersion = 100
        var cacheDir = Directory.create(TmpDir)
        var Illegal = false
        try {
            DiskLruCache.open(cacheDir, appVersion, -1, Int64(Int32.Max))
        }catch (e: Exception) {
            Illegal = true
        }
        
        @Assert(true, Illegal)    
    }
}

