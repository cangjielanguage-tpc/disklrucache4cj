//3rd_party_lib:disklrucache4cj/build/disklrucache
//3rd_party_lib:disklrucache4cj/build/charset

from disklrucache import disklrucache.*
from std import fs.*
from std import os.posix.*
from std import math.*
from fuzz import fuzz.*

var returnFlag: Int32 = 0
public func test_fuzz_DiskLruCache_edit_set(dp: DataProvider): Int32 {

    var str_vl = dp.consumeString(10)
    var path: String = getcwd()
    var TmpDir = path + "/test_fuzz_DiskLruCache_edit_set66"
    let appVersion = 100
    var cacheDir = Directory.create(TmpDir)
    var cache = DiskLruCache.open(cacheDir, appVersion, 4, Int64(Int32.Max))

    let key = "k1"
    let src = cache.edit(key).getOrThrow()
    try{
        src.set(0, str_vl)
        src.set(1, str_vl)
        src.commit()
        cache.delete()
    }catch (e:Exception) {
        if(Directory.exists(TmpDir)){
            Directory.delete(TmpDir,recursive:true)
        }
        returnFlag=-1
    }
    return returnFlag
}

main(){
    Fuzzer(test_fuzz_DiskLruCache_edit_set).startFuzz()
    return 0
}