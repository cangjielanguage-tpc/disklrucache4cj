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
public class disklrucache_getSnapshot_001 {
    @TestCase
    public func disklrucache_getSnapshot_001(): Unit {

        var path: String = getcwd()
        var TmpDir = path + "/disklrucache_getSnapshot_001"
        let appVersion = 100
        var cacheDir = Directory.create(TmpDir)
        var cache = DiskLruCache.open(cacheDir, appVersion, 2, Int64(Int32.Max))

        let key = "k1"
        let src = cache.edit(key).getOrThrow()
        src.set(0, "OP")
        src.set(1, "LKll")
        src.commit()
        let sc = cache.get("k1").getOrThrow().getString(0)

        @Assert("OP", sc)
    }
    @TestCase
    public func disklrucache_getSnapshot_002(): Unit {

        var path: String = getcwd()
        var TmpDir = path + "/disklrucache_getSnapshot_002"
        let appVersion = 100
        var cacheDir = Directory.create(TmpDir)
        var cache = DiskLruCache.open(cacheDir, appVersion, 2, Int64(Int32.Max))

        let key = "k1"
        let src = cache.edit(key).getOrThrow()
        src.set(0, "OP")
        src.set(1, "LKll")
        src.commit()
        var strmsg = ""
        try{
            cache.get("k2").getOrThrow()
        } catch (e : NoneValueException) {
            strmsg = "NoneValueException"
        }
        println("e.message : ${strmsg} ")

        @Assert(strmsg, "NoneValueException")
    }
}

