// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import disklrucache.*
import std.io.*
import std.fs.*
import std.posix.*
import std.unittest.*
import std.unittest.testmacro.*
import std.math.*
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

