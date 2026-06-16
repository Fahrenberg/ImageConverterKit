//
//  CompressionQuality.swift
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 27.10.2024.
//

import AVFoundation
import OSLog
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import Extensions


extension PlatformImage {
    /// HEIC Image Compression (more efficient, slower)
    ///
    /// Use it only with [supported devices for HEIC](https://support.apple.com/en-us/HT207022)
    public func heicDataCompression(compressionQuality: CGFloat) -> Data? {
        // Ensure compressionQuality is between 0 and 1
        let quality = min(max(compressionQuality, 0), 1)
        // 1.0 equals no compression
        //  HEVC Codec Design: The HEVC (H.265) codec, underlying HEIC, optimizes for high compression efficiency rather than supporting true lossless encoding. Setting the compression factor to 1.0 essentially requests a lossless image, but HEVC isn't designed for this mode in most implementations, causing the encoding operation to fail
        //
        guard quality != 1.0 else {
             return self.pngData()
        }
        
        let data = NSMutableData()
        let imageDestination = CGImageDestinationCreateWithData(
            data, AVFileType.heic as CFString, 1, nil
        )

        #if canImport(UIKit)
        let cgImage = self.cgImage
        #elseif canImport(AppKit)
        let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil)
        #endif

        guard let cgImage, let imageDestination else {
            return nil
        }

        let options: NSDictionary = [
            kCGImageDestinationLossyCompressionQuality: quality
        ]

        CGImageDestinationAddImage(imageDestination, cgImage, options)
        guard CGImageDestinationFinalize(imageDestination) else {
            return nil
        }

        return data as Data
    }

    /// JPG Image Compression (faster, less efficient)
    #if canImport(UIKit)
    public func jpgDataCompression(compressionQuality: CGFloat) -> Data? {
        let quality = min(max(compressionQuality, 0), 1)
        return jpegData(compressionQuality: quality)
    }
    #elseif canImport(AppKit)
    public func jpgDataCompression(compressionQuality: CGFloat) -> Data? {
        let quality = min(max(compressionQuality, 0), 1)
        let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        let properties = [
            NSBitmapImageRep.PropertyKey.compressionFactor: quality
        ]
        let jpegData = bitmapRep.representation(
            using: NSBitmapImageRep.FileType.jpeg, properties: properties
        )
        return jpegData
    }
    #else
    public func jpgDataCompression(compressionQuality: CGFloat) -> Data? {
        fatalError("Unsupported platform (iOS or macOS only)")
    }
    #endif
}
