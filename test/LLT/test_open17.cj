// DEPENDENCE: ./DiskLruCacheTest
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
        var TmpDir = path + "/DiskLruCacheTest"
        let appVersion = 100
        var cacheDir = Directory(TmpDir) 
        var cache = DiskLruCache.open(cacheDir, appVersion, 2, Int64(Int32.Max))
        let key = "k1"
        let src = cache.edit(key).getOrThrow()
        src.set(0, "ABC")
        src.set(1, "DE")
        let pc = src.getString(0).isEmpty()
        src.commit()
        
        @Assert(false, pc)    
    }
}

