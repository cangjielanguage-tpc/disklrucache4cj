// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from disklrucache import disklrucache.*
from std import io.*
from std import fs.*
from std import time.*
from std import os.posix.*
from std import unittest.*
from std import unittest.testmacro.*

@Test
public class LruCacheOpen1Test {
    @TestCase
    public func runBench():Unit{
        let n = 10000
        var path: String = getcwd()
        var TmpDir = path + "/DiskLruCacheTest"
        let appVersion = 100
        var cacheDir: Directory
        if (Directory.exists(TmpDir)) {
            cacheDir = Directory(TmpDir)
        } else {
            cacheDir = Directory.create(TmpDir)
        }
        var cache = DiskLruCache.open(cacheDir, appVersion, 2, Int64(Int32.Max))
    	let s = Time.now()
    	for (i in 0..n){
    	    let src = cache.edit("k1").getOrThrow()
            src.set(0, "ABC")
            src.set(1, "DE")
            src.commit()
    	}
    	let e = Time.since(s).nanoseconds()
    	println("[ PASSED ] CASE: testEventbus_${n} (${e} ns, ${e/n} ns/op)\n")
        @Assert(false, cache.isClosed())
    }
}

main(){
    let lrucache = LruCacheOpen1Test()
    lrucache.runBench()
}