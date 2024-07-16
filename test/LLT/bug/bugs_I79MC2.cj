// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import disklrucache.*
import std.io.*
import std.fs.*
import std.os.posix.*
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
        var TmpDir = path + "/DiskLruCacheTest_I79MC2"
        let appVersion = 100
        var cacheDir = Directory.create(TmpDir)
        var cache = DiskLruCache.open(cacheDir, appVersion, 2, Int64(Int32.Max))
        var input = false
        try {
            cache.setMaxSize(-5)
        } catch (e: DiskLruCacheException) {
            input = true
        }
        @Assert(true, input)

    }
}

