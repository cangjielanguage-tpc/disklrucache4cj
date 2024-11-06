// DEPENDENCE: ./DiskLruCacheTest44
// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import disklrucache.*
import std.io.*
import std.fs.*
import std.posix.*
import std.unittest.*
import std.unittest.testmacro.*
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
        var TmpDir = path + "/DiskLruCacheTest44"
        let appVersion = 10
        var cacheDir = Directory(TmpDir) 
        var cache = DiskLruCache.open(cacheDir, appVersion, 6, 1)
        let sc = cache.getMaxSize()
        @Assert(1, sc)
    }
}

