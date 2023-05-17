// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from disklrucache import disklrucache.*
from std import io.*
from std import fs.*
from std import os.posix.*
from std import unittest.*
from std import unittest.testmacro.*
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
        var TmpDir = path + "/DiskLruCacheTest"
        let appVersion = 100
        var cacheDir = Directory.create(TmpDir)
        var cache = DiskLruCache.open(cacheDir, appVersion, 2, Int64(Int32.Max))

        @Assert(TmpDir, cache.getDirectory().info.path.toString())
        @Assert(2147483647, cache.getMaxSize())

    }
}

