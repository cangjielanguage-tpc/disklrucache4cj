//3rd_party_lib:disklrucache4cj/build/disklrucache
//3rd_party_lib:disklrucache4cj/build/charset

from disklrucache import disklrucache.*
from std import fs.*
from std import os.posix.*
from std import math.*
from fuzz import fuzz.*

var returnFlag: Int32 = 0
public func fuzz_DiskLruCache_setMaxSize(dp: DataProvider): Int32 {
    var path: String = getcwd()
    var TmpDir = path + "/disklrucache_setMaxSize_001"
    let appVersion = 100
    try {
        var cacheDir = Directory.create(TmpDir)
        var cache = DiskLruCache.open(cacheDir, appVersion, 2, Int64(Int32.Max))
        cache.setMaxSize(dp.consumeInt64())
        cache.delete()
    } catch (e: Exception) {
        if(Directory.exists(TmpDir)){
            Directory.delete(TmpDir,recursive:true)
        }
    }
	
    return returnFlag
}

main(){
    Fuzzer(fuzz_DiskLruCache_setMaxSize).startFuzz()      
    return 0
}