export declare class DiskLruCacheExceptionArkTs {
    getMessage(): string
    toString(): string
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
}

export declare class SnapshotArkTs {
    edit(): EditorArkTs
    getString(index: number): string
    getLength(index: number): number
    close(): void
    getSequenceNumber(): number
    getInputStream(index: number): string
}

export declare class SeekPositionArkTs {
}

export declare class OpenModeArkTs {
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
}

export declare class EditorArkTs {
    abort(): void
    getString(index: number): string
    set(index: number, value: string): void
    commit(): void
    abortUnlessCommitted(): void
    newInputStream(index: number): ArrayBuffer
    newOutputStream(index: number): string
}


export declare interface CustomLib {
    EditorArkTs: {new (key: string, expectedSequenceNumber: number, cacheArkTs: DiskLruCacheArkTs): EditorArkTs}
    SnapshotArkTs: {new (key: string, cacheArkTs: DiskLruCacheArkTs): SnapshotArkTs}
    DiskLruCacheArkTs: {new (directory: string, appVersion: number, valueCount: number, maxSize: number): DiskLruCacheArkTs}
    FileArkTs: {new (path: string, openMode: OpenModeArkTs): FileArkTs}
    OpenModeArkTs: {new (typ: number, read: boolean, write: boolean): OpenModeArkTs}
    SeekPositionArkTs: {new (typ: number, seek: number): SeekPositionArkTs}
    DiskLruCacheExceptionArkTs: {new (messages: string): DiskLruCacheExceptionArkTs}
}