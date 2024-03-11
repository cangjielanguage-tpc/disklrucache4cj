/*
 * Copyright (c) Cangjie Library Team 2023-2023. All rights reserved.
 * Description:
 */
package disklrucache

from std import io.*
from std import fs.*
from std import collection.*
from std import unicode.*
from std import os.posix.*
from std import convert.*
from std import regex.*

public class DiskLruCache {

    static let JOURNAL_FILE: String = "journal"
    static let JOURNAL_FILE_TEMP: String = "journal.tmp"
    static let JOURNAL_FILE_BACKUP: String = "journal.bkp"
    static let MAGIC: String = "libcore.io.DiskLruCache"
    static let VERSION_1: String = "1"
    static let ANY_SEQUENCE_NUMBER: Int64 = -1

    static let LEGAL_KEY_PATTERN: Regex = Regex("[a-z0-9_-]{1,64}")
    private static let CLEAN: String = "CLEAN"
    private static let DIRTY: String = "DIRTY"
    private static let REMOVE: String = "REMOVE"
    private static let READ: String = "READ"


    protected var directory: Directory
    private var journalFile: Path
    private var journalFileTmp: Path
    private var journalFileBackup: Path
    private var appVersion: Int64
    private var maxSize: Int64
    protected var valueCount: Int64
    private var size: Int64 = 0
    private var journalWriter: Option<Sink> = Option<Sink>.None
    private var lruEntries: HashMap<String, Entry> = HashMap<String, Entry>()
    private var redundantOpCount: Int64 = 0
    private var nextSequenceNumber: Int64 = 0

    let lock: Monitor = Monitor()

    private init(directory: Directory, appVersion: Int64, valueCount: Int64, maxSize: Int64) {
        this.directory = directory
        this.appVersion = appVersion
        this.journalFile = directory.info.path.join(JOURNAL_FILE)
        this.journalFileTmp = directory.info.path.join(JOURNAL_FILE_TEMP)
        this.journalFileBackup = directory.info.path.join(JOURNAL_FILE_BACKUP)
        this.valueCount = valueCount
        this.maxSize = maxSize

    }

    public static func open(directory: Directory, appVersion: Int64, valueCount: Int64, maxSize: Int64): DiskLruCache {
        if (maxSize <= 0) {
            throw DiskLruCacheException("the max size of cache cannot be negative")
        }
        if (valueCount <= 0) {
            throw DiskLruCacheException("the number of values per cache entry cannot be negative")
        }

        // If a bkp file exists, use it instead.
        var backupFile = directory.info.path.join(JOURNAL_FILE_BACKUP)
        if (File.exists(backupFile)) {
            var journalFile = directory.info.path.join(JOURNAL_FILE)
            // If journal file also exists just delete backup file.
            if (File.exists(journalFile)) {
                File.delete(backupFile)
            } else {
                renameTo(backupFile, journalFile, true)
            }
        }

        // Prefer to pick up where we left off.
        var cache: DiskLruCache = DiskLruCache(directory, appVersion, valueCount, maxSize)
        if (File.exists(cache.journalFile)) {

                try {
                    cache.readJournal()
                    cache.processJournal()  
                    cache.journalWriter = ReallBufferSink(FileSink(File(cache.journalFile, Append)))
                    return cache
                } catch (e: Exception) {
                    cache.delete()
                }
            
        }

        cache = DiskLruCache(directory, appVersion, valueCount, maxSize)
        cache.rebuildJournal()
        return cache
    }

    public func delete(): Unit {
        close()
        Util.deleteContents(directory)
    }

    public func close(): Unit{
        match (journalWriter) {
            case None =>
                return
            case Some(_) =>
                ()
        }

        for (entry in lruEntries.values()) {
            match (entry.currentEditor) {
                case None =>
                    ()
                case Some(s) =>
                    s.abort()
            }
        }
        trimToSize()
        journalWriter.getOrThrow().close()
        journalWriter = None
  
    }

    private func trimToSize(): Unit {
        while (size > maxSize) {
            let toEvict: String = lruEntries.keys().iterator().next().getOrThrow()
            remove(toEvict)
        }
    }

    public func remove(key: String): Bool {
        synchronized (lock) {
            checkNotClosed()
            validateKey(key)
            match (lruEntries.get(key)) {
                case Some(k) => 
                    match (k.currentEditor) {
                        case Some(_) => return false
                        case None => ()
                    }
                    for (i in 0..valueCount) {
                        let file = k.getCleanFile(i)
                        file.close()
                        deleteIfExists(file.info.path)
                        size -= k.lengths[i]
                        k.lengths[i] = 0
                    }
                    redundantOpCount++
                    var jw = wirteSink(journalWriter)
                    jw.write(REMOVE.toArray())
                    jw.write(" ".toArray())
                    jw.write(key.toArray())
                    jw.write("\n".toArray())
                    lruEntries.remove(key)

                    if (journalRebuildRequired()) {
                        cleanUp()
                    }

                    return true
                case None => return false
            }
        }
    }

    private func wirteSink(journalWriter: Option<Sink>): Sink {
        return journalWriter.getOrThrow()
    }

    private func processJournal(): Unit {
        deleteIfExists(journalFileTmp)
        var str = ArrayList<String>()
        for (key in lruEntries.keys()) {
            let entry = lruEntries[key]
            match (entry.currentEditor) {
                case None =>
                    for (i in 0..valueCount) {
                        size += entry.lengths[i]
                    }
                case Some(_) =>
                    entry.currentEditor = None
                    for (i in 0..valueCount) {
                        let cleanfiles = entry.getCleanFile(i)
                        cleanfiles.close()
                        let dirtyfiles = entry.getDirtyFile(i)
                        dirtyfiles.close()
                        deleteIfExists(cleanfiles.info.path)
                        deleteIfExists(dirtyfiles.info.path)
                    }
                    str.append(key)
            }
        }
        lruEntries.removeAll(str)
    }

    private func rebuildJournal(): Unit {
        synchronized (lock) {
            match (journalWriter) {
                case None =>
                    ()
                case Some(s) =>
                    s.close()
            }
            
            var filejournals: File
            if (File.exists(journalFileTmp)) {
                filejournals = File(journalFileTmp, Open(true,true))
            } else {
                filejournals = File(journalFileTmp, Create(true))
            }
            var writer = ReallBufferSink(FileSink(filejournals))
            try {
                writer.write(MAGIC.toArray())
                writer.write("\n".toArray())
                writer.write(VERSION_1.toArray())
                writer.write("\n".toArray())
                writer.write("${appVersion}".toArray())
                writer.write("\n".toArray())
                writer.write("${valueCount}".toArray())
                writer.write("\n".toArray())
                writer.write("\n".toArray())
                for (entry in lruEntries.values()) {
                    match (entry.currentEditor) {
                        case Some(_) =>
                            writer.write((DIRTY+ " ").toArray())
                            writer.write(entry.key.toArray())
                            writer.write("\n".toArray())
                        case None =>
                            writer.write((CLEAN+ " ").toArray())
                            writer.write(entry.key.toArray())
                            writer.write(entry.getLengths().toArray())
                            writer.write("\n".toArray())
                    }
                }
            } finally {
                writer.close()
            }
            if (File.exists(journalFile)) {
                renameTo(journalFile, journalFileBackup, true);
            }  
            renameTo(journalFileTmp, journalFile, false);
            if (File.exists(journalFileBackup)) {
                File.delete(journalFileBackup)
            }   
            journalWriter = ReallBufferSink(FileSink(File(journalFile, Append)))
        }
    }

    private func readJournal(): Unit {
        var reader: StrictLineReader =  StrictLineReader(File(journalFile, Open(true,true)), Util.US_ASCII)

        try {
            let magic = reader.readLine()
            let version = reader.readLine()
            let appVersionString = reader.readLine()
            let valueCountString = reader.readLine()
            let blank = reader.readLine()
            if (MAGIC != (magic) || VERSION_1 != (version) || ("${appVersion}") != (appVersionString) || ("${valueCount}") != (valueCountString) || "" != (blank)) {
                
                throw DiskLruCacheException("unexpected journal header: [${magic}, ${version}, ${valueCountString}, ${blank}]")
            }

            var lineCount = 0

            while (true) {
                try {
                    readJournalLine(reader.readLine())
                    lineCount++
                } catch (e: Exception) {
                    break
                }
            }
            redundantOpCount = lineCount - lruEntries.size
        } finally {
            reader.close()
        }
    }

    private func readJournalLine(line: String): Unit {
        var firstSpace = -1
        try {
            firstSpace = line.indexOf(" ").getOrThrow()
        } catch (e: Exception) {
            throw DiskLruCacheException("unexpected journal line: ${line}")
        }
        let keyBegin = firstSpace + 1
        var key: String = ""
        var secondSpace = -1
        var secondSpaceds: Bool = false
        try {
            secondSpace = line.indexOf(" ", keyBegin).getOrThrow()
        } catch (e: Exception) {
            secondSpaceds = true
        }
        if (secondSpaceds) {
            key = line[keyBegin..]
            if (firstSpace == REMOVE.size && line.startsWith(REMOVE)) {
                lruEntries.remove(key)
                return
            }
        } else {
            key = line[keyBegin..secondSpace]
        }

        var entry = Entry("",this)
        try {
            entry = lruEntries.get(key).getOrThrow()
        } catch (e: Exception) {
            entry = Entry(key,this)
            lruEntries.put(key, entry)
        }

        if (secondSpace != -1 && firstSpace == CLEAN.size && line.startsWith(CLEAN)) {
            let parts: Array<String> = line[(secondSpace + 1)..].split(" ")
            entry.readable = true
            entry.currentEditor = None
            entry.setLengths(parts)
        } else if (secondSpace == -1 && firstSpace == DIRTY.size && line.startsWith(DIRTY)) {
            entry.currentEditor = Editor(entry,this)
        } else if (secondSpace == -1 && firstSpace == READ.size && line.startsWith(READ)) {
          
        } else {
            throw DiskLruCacheException("unexpected journal line: ${line}")
        }
    }

    private static func deleteIfExists(file: Path): Unit {
        if (File.exists(file)) {
            try {
                File.delete(file)
            }catch (e: Exception){
                throw DiskLruCacheException("failed to delete ")
            }  
            
        }
    }

    private static func renameTo(fo: Path, to: Path, deleteDestination: Bool): Unit {
        if (deleteDestination) {
            deleteIfExists(to)
        }
        File.move(fo,to, true)

    }

    private func cleanUp(): Unit {
        synchronized (lock) {
            match (journalWriter) {
                case Some(_) => ()
                case None => return
            }
            trimToSize()
            if (journalRebuildRequired()) {
                rebuildJournal()
                redundantOpCount = 0
            }
        }
    }

    private func validateKey(key: String): Unit {
        let matcher: Option<MatchData> = LEGAL_KEY_PATTERN.matcher(key).fullMatch()

        match (matcher) {
            case Some(_) => ()
            case None => throw DiskLruCacheException("keys must match regex [a-z0-9_-]{1,64}: \"" + "${key}" + "\"")
        }

    }

    public func getDirectory(): Directory {
        return directory
    }

    public func getMaxSize(): Int64 {
        return maxSize
    }

    public func setMaxSize(maxSize: Int64): Unit {
        if (maxSize <= 0) {
            throw DiskLruCacheException("invalid cache size: ${maxSize}")
        }
        this.maxSize = maxSize
        cleanUp()
    }

    public func getSize(): Int64 {
        return size
    }

    protected func completeEdit(editor: Editor, success: Bool): Unit {
        synchronized (lock) {
            let entry = editor.entry
            if (!refEq(entry.currentEditor.getOrThrow(), editor)) { throw  Exception("editor is others") }
            if (success && !entry.readable) {
                for (i in 0..valueCount) {
                    if (!editor.written.getOrThrow()[i]) {
                        editor.abort()
                        throw DiskLruCacheException("newly created entry didn't create value for index ${i}")
                    }
                    if (!File.exists(entry.getDirtyFile(i).info.path.toString())) {
                        editor.abort()
                        return
                    }
                }
            }
            for (i in 0..valueCount) {
                let dirty = entry.getDirtyFile(i)
                if (success && File.exists(dirty.info.path.toString()) ) {
                    let clean = entry.getCleanFile(i)
                    File.move(dirty.info.path.toString(),clean.info.path.toString(), true)
                    let oldLength = entry.lengths[i]
                    let newLength = FileInfo(clean.info.path.toString()).length
                    clean.close()
                    entry.lengths[i] = newLength
                    size = size - oldLength + newLength
                } else if (!success) { deleteIfExists(dirty.info.path) }
            }
            redundantOpCount++
            entry.currentEditor = None
            var jw = wirteSink(journalWriter)
            if (entry.readable || success) {
                entry.readable = true
                jw.write((CLEAN + " ").toArray())
                jw.write(entry.key.toArray())
                jw.write(entry.getLengths().toArray())
                jw.write("\n".toArray())
                if (success) {
                    entry.sequenceNumber = nextSequenceNumber
                    nextSequenceNumber++
                }
            } else {
                lruEntries.remove(entry.key)
                jw.write((REMOVE + " ").toArray())
                jw.write(entry.key.toArray())
                jw.write("\n".toArray())
            }
            jw.flush()
            if (size > maxSize || journalRebuildRequired()) { cleanUp() }
        }
    }

    private func journalRebuildRequired(): Bool {
        let redundantOpCompactThreshold = 2000
        return redundantOpCount >= redundantOpCompactThreshold && redundantOpCount >= lruEntries.size
    }

    public func isClosed(): Bool {
        synchronized (lock) {
            match (journalWriter) {
                case Some(_) => return false
                case None => return true
            }
        }
    }

    private func checkNotClosed(): Unit {
        match (journalWriter) {
            case Some(_) => ()
            case None => 
                throw DiskLruCacheException("cache is closed")
        }
    }

    public func flush(): Unit {
        synchronized (lock) {
            checkNotClosed()
            trimToSize()
            journalWriter.getOrThrow().flush()
        }
    }

    protected static func inputStreamToString(ins: InputStream): String {
        return Util.readFully(StringReader(ins))
    }

    public func edit(key: String): Option<Editor> {
        return edit(key, ANY_SEQUENCE_NUMBER)
    }

    protected func edit(key: String, expectedSequenceNumber: Int64): Option<Editor> {
        synchronized (lock) {
            checkNotClosed()
            validateKey(key)
            var entrys: Option<Entry> = lruEntries.get(key)
            var entry = Entry(key, this)
            var hasNull: Bool = false
            match (entrys) {
                case Some(v) => 
                    entry = v
                case None => 
                    hasNull = true
            }
            if (expectedSequenceNumber != ANY_SEQUENCE_NUMBER && (hasNull || entry.sequenceNumber != expectedSequenceNumber)) {
                return None
            }

            if (hasNull) {
                entry = Entry(key, this)
                lruEntries.put(key, entry)
            } 
            match (entry.currentEditor) {
                case Some(_) => 
                    return None
                case None => 
                    ()
            }

            var editor = Editor(entry,this)
            entry.currentEditor = Option<Editor>.Some(editor)

            let jw = journalWriter.getOrThrow()
            jw.write(DIRTY.toArray())
            jw.write(" ".toArray())
            jw.write(key.toArray())
            jw.write("\n".toArray())
            jw.flush()
            return Option<Editor>.Some(editor)
        }
    }

    public func get(key: String): Option<Snapshot> {
        synchronized (lock) { 
            checkNotClosed()
            validateKey(key)

            var entryso: Option<Entry> = lruEntries.get(key)
            var entry = Entry(key, this)
            match (entryso) {
                case Some(v) => 
                    entry = v
                case None => 
                    return None
            }

            if (!entry.readable) {
                return None
            }

            var ins: Array<File> = Array<File>(valueCount, item: unsafe{zeroValue<File>()})
            for (i in 0..valueCount) {
                ins[i] = entry.getCleanFile(i)
            }
            redundantOpCount++
            let jw = journalWriter.getOrThrow()
            jw.write(READ.toArray())
            jw.write(" ".toArray())
            jw.write(key.toArray())
            jw.write("\n".toArray())

            if (journalRebuildRequired()) {
                 cleanUp()
            }
            return Snapshot(key, entry.sequenceNumber, ins, entry.lengths, this)
        }
    }
}

class Entry { 

    protected var key: String
    protected var lengths: Array<Int64>
    protected var readable: Bool = false
    protected var currentEditor: Option<Editor> = None
    protected var sequenceNumber: Int64 = 0
    private var disk: DiskLruCache

    init(key: String, disk: DiskLruCache) {
        this.disk = disk
        this.key = key
        this.lengths = Array<Int64>(disk.valueCount, item: 0)
    }

    public func getLengths(): String {
        var result = StringBuilder()
        for (src in lengths) {
            result.append(' ')
            result.append(src)
        }
        return result.toString()
    }

    public func setLengths(strings: Array<String>): Unit {
        if (strings.size != disk.valueCount) {
            throw DiskLruCacheException("unexpected journal line: ${strings.toString()}" )
        }
        
        try {
            for (i in 0..strings.size) {
                lengths[i] = Int64.parse(strings[i])
            }
        } catch (e: Exception) {
            throw DiskLruCacheException("unexpected journal line: ${strings.toString()}" )
        }
    }

    public func getCleanFile(i: Int64): File {
        if(File.exists(disk.directory.info.path.join(key+"."+"${i}"))) {
            return File(disk.directory.info.path.join(key+"."+"${i}"), Open(true,true))
        } else {
            return File(disk.directory.info.path.join(key+"."+"${i}"), Create(true))
        }
    }

    public func getDirtyFile(i: Int64): File {
        if(File.exists(disk.directory.info.path.join(key+"."+"${i}"+".tmp"))) {
            return File(disk.directory.info.path.join(key+"."+"${i}"+".tmp"), Open(true,true))
        } else {
            return File(disk.directory.info.path.join(key+"."+"${i}"+".tmp"), Create(true))
        }
    }
}

public class Editor {
    var entry: Entry
    protected let written: Option<Array<Bool>>
    private var hasErrors: Bool = false
    private var committed: Bool = false
    private let disk: DiskLruCache
    private let lock: Monitor = Monitor()

    init(entry: Entry, disk: DiskLruCache) {
        this.entry = entry
        this.disk = disk
        this.written = if (!entry.readable) {
            Array<Bool>(disk.valueCount, item: false)
        } else {
            Option<Array<Bool>>.None
        }
    }

    public func abort(): Unit {
        disk.completeEdit(this, false)
    }

    public func newInputStream(index: Int64): Option<InputStream> {
        synchronized (disk.lock) {
            if(!refEq(entry.currentEditor.getOrThrow(), this)) {
                throw DiskLruCacheException("editor object inconsistency")
            }
            if (!entry.readable) {
                return Option<InputStream>.None
            }

            try {
                return Option<InputStream>.Some(entry.getCleanFile(index))
            } catch (e: Exception) {
                return Option<InputStream>.None
            }
        }
    }

    public func getString(index: Int64): String {
        let inse: Option<InputStream> = newInputStream(index)
        match (inse) {
            case Some(K) => 
                return DiskLruCache.inputStreamToString(K)
            case None => 
                return ""
        }
    }

    public func newOutputStream(index: Int64): File {
        synchronized(disk.lock) {
            if(!refEq(entry.currentEditor.getOrThrow(), this)) {
                throw DiskLruCacheException("editor object inconsistency")
            }
            if (!entry.readable) {
                let writtense = written.getOrThrow()
                writtense[index] = true
            }
            let dirtyFile: File = entry.getDirtyFile(index)
            return dirtyFile
        }
    }

    public func set(index: Int64, value: String): Unit {
        let writer = newOutputStream(index)
        try {
            if (writer.canWrite()) {
                writer.write(value.toArray())
            }
        } finally {
            writer.close()
        }
        
    }

    public func commit(): Unit {
        if (hasErrors) {
            disk.completeEdit(this, false)
            disk.remove(entry.key)
        } else {
            disk.completeEdit(this, true)
        }
        committed = true
    }

    public func abortUnlessCommitted(): Unit {
        if (!committed) {
            try {
                abort()
            } catch (ignored: Exception) {
            }
        }
    }
}


public class Snapshot {
    private var buff = StringBuilder()
    private var buffArr = Array<Byte>(8192, item: 0)
    private var key: String
    private var sequenceNumber: Int64
    private var ins: Array<File>
    private var lengths: Array<Int64>
    private var disk: DiskLruCache
    private var isClosed: Bool = false

    init(key: String, sequenceNumber: Int64, ins: Array<File>, lengths: Array<Int64>, disk: DiskLruCache) {
        this.key = key
        this.sequenceNumber = sequenceNumber
        this.ins = ins
        this.lengths = lengths
        this.disk = disk
    }

    public func edit(): Option<Editor> {
        return disk.edit(key, sequenceNumber)
    }

    public func getInputStream(index: Int64): File {
        if (isClosed) {
            throw DiskLruCacheException("stream closed")
        }
        let src = ins.get(index).getOrThrow()
        return src
    }

    public func getString(index: Int64): String {
        buff.reset()
        let file = getInputStream(index)
        var read = file.read(buffArr)
        while (read != 0) {
            unsafe {buff.appendFromUtf8Unchecked(buffArr.slice(0, read))}
            read = file.read(buffArr)
        }
        return buff.toString()
    }

    public func getLength(index: Int64): Int64 {
        return lengths[index]
    }

    public func close(): Unit {
        isClosed = true
        for (fse in ins) {
            Util.closeQuietly(fse)
        }
    }

}

public class DiskLruCacheException <: Exception {
    private var messages: String = ""
    public init() {
        super()
    }

    public init(messages: String) {
        super(messages)
        this.messages = messages
    }

    public func getMessage(): String {
        return messages
    }
    public override func toString(): String {
        return "DiskLruCacheException: ${messages}"
    }
}
