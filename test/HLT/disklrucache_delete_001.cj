//3rd_party_lib:disklrucache4cj/target/release/disklrucache
//3rd_party_lib:disklrucache4cj/target/release/charset4cj

import disklrucache.*
import std.io.*
import std.fs.*
import std.posix.*
import std.unittest.*
import std.unittest.testmacro.*
import std.math.*
@Test
public class disklrucache_delete_001 {
    @TestCase
    public func disklrucache_delete_001(): Unit {

        var path: String = getcwd()
        var TmpDir = path + "/disklrucache_delete_001"
        let appVersion = 100
        var cacheDir = Directory.create(TmpDir)
        var cache = DiskLruCache.open(cacheDir, appVersion, 2, Int64(Int32.Max))

        println("cache.getDirectory() :${cache.getDirectory().info.path.toString()}")
        println("cache.getMaxSize() :${cache.getMaxSize()}")
        @Assert(cache.getDirectory().info.path.toString().contains("disklrucache_delete_001"))
        @Assert(cache.getMaxSize(), Int64(Int32.Max))
        cache.delete()
        println("cache.getDirectory() :${cache.getDirectory().info.path.toString()}")
        println("cache.isClosed() :${cache.isClosed()}")
        @Assert(cache.getDirectory().info.path.toString().contains("disklrucache_delete_001"))
        @Assert(cache.isClosed(), true)

    }
}

