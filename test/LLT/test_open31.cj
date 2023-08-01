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
        var cacheDir = Directory.create(TmpDir) 
        var cache = DiskLruCache.open(cacheDir, appVersion, 6, Int64(Int32.Max))
        let key = "k1"
        let src = cache.edit(key).getOrThrow()
        src.set(0, "ABC")
        src.set(1, "DE")
        src.set(2, "FG")
        src.set(3, "HI")
        src.set(4, "HI")
        src.set(5, "HI")
        src.getString(0).isEmpty()
        src.commit() 
        let str = cache.getMaxSize()
        @Assert(2147483647, str)    
    }
}

