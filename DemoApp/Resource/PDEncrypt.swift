import Foundation
import Compression


public final class Encrypt {
    
    public enum Algorithm {
        case LZ4
        case LZFSE
        case LZMA
        case ZLIB
        
        public func algorithm() -> compression_algorithm {
            switch self {
            case .LZ4: return COMPRESSION_LZ4
            case .LZFSE: return COMPRESSION_LZFSE
            case .LZMA: return COMPRESSION_LZMA
            case .ZLIB: return COMPRESSION_ZLIB
            }
        }
    }
    
    private let algorithm: Algorithm
    
    private let bufferSize: Int
    
    public init(algorithm: Algorithm, bufferSize: Int = 0x20000) {
        self.algorithm = algorithm
        self.bufferSize = bufferSize
    }
    
    public func encryptData(data: NSData) -> NSData? {
        return processData(inputData: data, algorithm: algorithm, bufferSize: bufferSize, encrypt: true)
    }
    
    public func decryptData(data: NSData) -> NSData? {
        return processData(inputData: data, algorithm: algorithm, bufferSize: bufferSize, encrypt: false)
    }
    
    private func processData(inputData: NSData, algorithm: Algorithm, bufferSize: Int, encrypt: Bool) -> NSData? {
        guard inputData.length > 0 else { return nil }
        
        var stream = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1).pointee
        
        let initStatus = compression_stream_init(&stream, encrypt ? COMPRESSION_STREAM_ENCODE : COMPRESSION_STREAM_DECODE, algorithm.algorithm())
        guard initStatus != COMPRESSION_STATUS_ERROR else {
            print("[Encrypt] \(encrypt ? "Encrypt" : "Decrypt") with \(algorithm) failed to init stream with status \(initStatus).")
            return nil
        }

        defer {
            compression_stream_destroy(&stream)
        }
        
        stream.src_ptr = inputData.bytes.assumingMemoryBound(to: UInt8.self)    //UnsafePointer<UInt8>(inputData.bytes)
        stream.src_size = inputData.length
        
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        stream.dst_ptr = buffer
        stream.dst_size = bufferSize
        let outputData = NSMutableData()
        
        while true {
            let status = compression_stream_process(&stream, Int32(encrypt ? COMPRESSION_STREAM_FINALIZE.rawValue : 0))
            if status == COMPRESSION_STATUS_OK {
                guard stream.dst_size == 0 else { continue }
                outputData.append(buffer, length: bufferSize)
                stream.dst_ptr = buffer
                stream.dst_size = bufferSize
            } else if status == COMPRESSION_STATUS_END {
                guard stream.dst_ptr > buffer else { continue }
                outputData.append(buffer, length: stream.dst_ptr - buffer)
                return outputData
            } else if status == COMPRESSION_STATUS_ERROR {
                print("[Encrypt] \(encrypt ? "Encrypt" : "Decrypt") with \(algorithm) failed with status \(status).")
                return nil
            }
        }
    }
}
