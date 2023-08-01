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
        var TmpDir = path + "/DiskTest666"
        let appVersion = 100
        var cacheDir = Directory.create(TmpDir) 
        var cache = DiskLruCache.open(cacheDir, appVersion, 4, Int64(Int32.Max))
        cache.setMaxSize(110)
        let stp = cache.getMaxSize()
        @Assert(110, stp)    
    }
}

