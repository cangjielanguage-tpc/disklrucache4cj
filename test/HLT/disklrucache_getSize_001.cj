//3rd_party_lib:disklrucache4cj/build/disklrucache
//3rd_party_lib:disklrucache4cj/build/charset

from disklrucache import disklrucache.*
from std import io.*
from std import fs.*
from std import os.posix.*
from std import unittest.*
from std import unittest.testmacro.*

@Test
public class disklrucache_getSize_001 {
    @TestCase
    public func disklrucache_getSize_001(): Unit {

        var path: String = getcwd()
        var TmpDir = path + "/disklrucache_getSize_001"
        let appVersion = 100
        var cacheDir = Directory.create(TmpDir)
        var cache = DiskLruCache.open(cacheDir, appVersion, 2, Int64(Int32.Max))

        println("cache.getDirectory() :${cache.getDirectory().info.path.toString()}")
        println("cache.getMaxSize() :${cache.getMaxSize()}")
        println("cache.getSize() :${cache.getSize()}")
        @Assert(cache.getDirectory().info.path.toString().contains("disklrucache_getSize_001"))
        @Assert(cache.getMaxSize(), Int64(Int32.Max))
        @Assert(cache.getSize(), Int64(0))
    }
}

