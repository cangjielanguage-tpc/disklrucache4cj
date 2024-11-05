// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import disklrucache.*
import std.io.*
import std.fs.*
import std.time.*
import std.posix.*
import std.unittest.*
import std.unittest.testmacro.*
import std.math.*
@Test
public class LruCacheOpen1Test {
    @TestCase
    public func runBench():Unit{
        let n = 1
        var path: String = getcwd()
        var TmpDir = path + "/DiskLruCacheTest"
        let appVersion = 100
        var cacheDir: Directory
        if (exists(TmpDir)) {
            cacheDir = Directory(TmpDir)
        } else {
            cacheDir = Directory.create(TmpDir)
        }
        var cache = DiskLruCache.open(cacheDir, appVersion, 2, Int64(Int32.Max))
    	let s = DateTime.now()
        var see = -1
    	for (i in 0..n){
    	    let src = cache.edit("k1").getOrThrow()
            src.set(0, "ABC")
            src.set(1, "DE")
            src.commit()
            see = i
    	}
    	let e = (DateTime.now()-s).toNanoseconds()
    	println("[ PASSED ] CASE: testEventbus_${n} (${e} ns, ${e/n} ns/op)\n")
        @Assert(false, cache.isClosed())
    }
}

main(){
    let lrucache = LruCacheOpen1Test()
    lrucache.runBench()
}