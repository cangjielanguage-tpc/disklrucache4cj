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
        var TmpDir = path + "/DiskLruCacheTest"
        let appVersion = 10
        let sc = 10086
        var cacheDir = Directory.create(TmpDir)
        var cache = DiskLruCache.open(cacheDir, appVersion, 2, Int64(Int32.Max))
        let src = cache.setMaxSize(10086)
        let src1 = cache.getMaxSize()
        @Assert(10086, src1)
    }
}

