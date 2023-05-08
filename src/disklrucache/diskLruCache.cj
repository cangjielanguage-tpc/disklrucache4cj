package disklrucache

from std import io.*
from std import fs.*
from std import collection.*
from std import unicode.*
from std import os.posix.*

public class DiskLruCache {

    static let JOURNAL_FILE: String = "journal"
    static let JOURNAL_FILE_TEMP: String = "journal.tmp"
    static let JOURNAL_FILE_BACKUP: String = "journal.bkp"
    static let MAGIC: String = "libcore.io.DiskLruCache"
    static let VERSION_1: String = "1"
    static let ANY_SEQUENCE_NUMBER: Int64 = -1

    

}
