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

    let lrucache = LruCacheOpenTest()
    lrucache.openTest()
    return 0
}

@Test
public class LruCacheOpenTest {
    @TestCase
    public func openTest(): Unit {

        var path: String = getcwd()
        var TmpDir = path + "/DiskLruCacheTest_I79MC2"
        let appVersion = 100
        var cacheDir = Directory.create(TmpDir)
        var cache = DiskLruCache.open(cacheDir, appVersion, 2, Int64(Int32.Max))
        var input = false
        try {
            cache.setMaxSize(-5)
        } catch (e: IllegalArgumentException) {
            input = true
        }
        @Assert(true, input)

    }
}

