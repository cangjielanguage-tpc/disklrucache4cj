export declare class DiskLruCacheExceptionArkTs {
    getMessage(): string
    toString(): string
    constructor (messages: string)
}

export declare class DiskLruCacheArkTs {
    edit(key: string, diskLruCacheArkTs: DiskLruCacheArkTs): EditorArkTs
    get(key: string, diskLruCacheArkTs: DiskLruCacheArkTs): SnapshotArkTs
    delete(): void
    close(): void
    remove(key: string): boolean
    getDirectory(): string
    getMaxSize(): number
    setMaxSize(maxSize: number): void
    getSize(): number
    isClosed(): boolean
    flush(): void
    constructor (directory: string, appVersion: number, valueCount: number, maxSize: number)
}

export declare class SnapshotArkTs {
    edit(): EditorArkTs
    getString(index: number): string
    getLength(index: number): number
    close(): void
    getSequenceNumber(): number
    getInputStream(index: number): string
    constructor (key: string, cacheArkTs: DiskLruCacheArkTs)
}

export declare class FileArkTs {
    length: number
    position: number
    remainLength: number
    close(): void
    flush(): void
    isClosed(): boolean
    read(buffer: ArrayBuffer): ArrayBuffer
    seek(sp: SeekPositionArkTs): number
    write(buffer: ArrayBuffer): void
    constructor (path: string, openMode: OpenModeArkTs)
}

export declare class SeekPositionArkTs {
    constructor (typ: number, seek: number)
}

export declare class OpenModeArkTs {
    constructor (typ: number, read: boolean, write: boolean)
}

export declare class EditorArkTs {
    abort(): void
    getString(index: number): string
    set(index: number, value: string): void
    commit(): void
    abortUnlessCommitted(): void
    newInputStream(index: number): ArrayBuffer
    newOutputStream(index: number): string
    constructor (key: string, expectedSequenceNumber: number, cacheArkTs: DiskLruCacheArkTs)
}



export declare function testCJ(s: string): string
