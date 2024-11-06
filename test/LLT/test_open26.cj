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
        let stp = cache.getMaxSize()
        @Assert(2147483647, stp)    
    }
}

