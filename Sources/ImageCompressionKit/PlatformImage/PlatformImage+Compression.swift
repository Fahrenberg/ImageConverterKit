//
//  PlatformImage+Compression.swift
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 17.06.2026.
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
        // 1.0 equals no compression, return pngData()
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


extension PlatformImage {

    /// Generic method to find the optimal compression quality for the target size
    ///
    /// Skips compression if the original image size (PNG format) is smaller than or equal to the askedMaxSize.
    /// If no size constraint is set, returns the original PNG data.
    ///
    private func findOptimalCompressionQuality(
        askedMaxSize: UInt64,
        compressionClosure: (Double) -> Data?
    ) -> Data? {
        // Check if the image's original PNG size is smaller or equal to askedMaxSize
        if let originalData = self.pngData(),
           askedMaxSize == .max || UInt64(originalData.count) <= askedMaxSize {
            Logger.source.debug(
                """
                Skipping compression as original image size (\(originalData.count) bytes)
                is smaller than or equal to the askedMaxSize (\(askedMaxSize == .max ? ".max" : String(describing: askedMaxSize)) bytes).
                """
            )
            return originalData
        }

        // Constants for the compression search algorithm
        let tolerance: Double = 0.1 // 10% tolerance
        let maxAttempts = 6 // Limit to avoid infinite loops in case of issues, approx to double digit suffcient
        // Initial bounds for the compression quality (0.0 - lowest, 1.0 - highest)
        var lowerBound: Double = 0.0
        var upperBound: Double = 1.0
        // Results
        var midQuality: Double = 1.0
        var attempts = 0

        while attempts < maxAttempts {
            midQuality = (lowerBound + upperBound) / 2.0

            // Compress the image with the current quality setting
            guard let compressedData = compressionClosure(midQuality) else {
                return nil // Return nil if compression fails
            }

            let dataSize = UInt64(compressedData.count)
            let minSize = UInt64(Double(askedMaxSize) * (1.0 - tolerance))
            let maxSize = UInt64(Double(askedMaxSize) * (1.0 + tolerance))

            // Check if the data size is within the 10% tolerance range
            if dataSize >= minSize && dataSize <= maxSize {
                Logger.source.debug(
                    """
                    Compression completed for askedMaxSize (\(askedMaxSize))
                    CompressionQuality: \(midQuality)
                    Used attempts: \(attempts)
                    """
                )
                return compressedData
            } else if dataSize > askedMaxSize {
                // Data size too large, reduce the compression quality
                upperBound = midQuality
            } else {
                // Data size too small, increase the compression quality
                lowerBound = midQuality
            }
            attempts += 1
        }
        Logger.source.error(
            """
            Compression not completed for askedMaxSize (\(askedMaxSize))
            Used attempts \(attempts) (max: \(maxAttempts))
            Using CompressionQuality: \(midQuality)
            """
        )
        // If max attempts are reached, use the best found compression quality
        return compressionClosure(midQuality)
    }

    /// Compress UIImage or NSImage to askedMaxSize (+/-10%) using HEIC format
    ///
    /// Skips compression if the original image size (PNG format) is smaller than or equal to the askedMaxSize.
    /// If no size constraint is set, returns the original PNG data.
    ///
    public func heicDataCompression(askedMaxSize: UInt64 = .max) -> Data? {
        return findOptimalCompressionQuality(askedMaxSize: askedMaxSize) { compressionQuality in
            return self.heicDataCompression(compressionQuality: compressionQuality)
        }
    }

    /// Compress UIImage or NSImage to askedMaxSize (+/-10%) using JPEG format
    ///
    /// Skips compression if the original image size (PNG format) is smaller than or equal to the askedMaxSize.
    /// If no size constraint is set, returns the original PNG data.
    ///
    public func jpgDataCompression(askedMaxSize: UInt64 = .max) -> Data? {
        return findOptimalCompressionQuality(askedMaxSize: askedMaxSize) { compressionQuality in
            return self.jpgDataCompression(compressionQuality: compressionQuality)
        }
    }
}


extension PlatformImage {
    public enum ImageAlignment {
        case left, center, right
    }
    
    public func resized(to targetSize: CGSize,
                        dpi: CGFloat = 72.0,
                        alignment: ImageAlignment = .center) -> PlatformImage? {
        let scaleFactor = dpi / 72.0
        let canvasSize = CGSize(width: targetSize.width * scaleFactor,
                                height: targetSize.height * scaleFactor)
        
        // Get the original image size
        let originalSize = self.size
        
        // Compute the scale factor to preserve the aspect ratio
        let widthRatio = canvasSize.width / originalSize.width
        let heightRatio = canvasSize.height / originalSize.height
        let uniformScale = min(widthRatio, heightRatio)
        
        // Determine the scaled image size
        let scaledImageSize = CGSize(width: originalSize.width * uniformScale,
                                     height: originalSize.height * uniformScale)
        
        // Compute the horizontal offset based on alignment
        let xOffset: CGFloat
        switch alignment {
        case .left:
            xOffset = 0
        case .center:
            xOffset = (canvasSize.width - scaledImageSize.width) / 2.0
        case .right:
            xOffset = canvasSize.width - scaledImageSize.width
        }
        
        // Center vertically
        let yOffset = (canvasSize.height - scaledImageSize.height) / 2.0
        let drawingRect = CGRect(origin: CGPoint(x: xOffset, y: yOffset),
                                 size: scaledImageSize)
        
#if canImport(UIKit)
        // For iOS, use UIGraphicsImageRenderer to create the image context.
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        return renderer.image { _ in
            self.draw(in: drawingRect)
        }
#elseif canImport(AppKit)
        // For macOS, create a new NSImage and draw into it.
        let newImage = NSImage(size: canvasSize)
        newImage.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        self.draw(in: NSRect(origin: CGPoint(x: xOffset, y: yOffset), size: scaledImageSize),
                  from: NSRect(origin: .zero, size: originalSize),
                  operation: .copy,
                  fraction: 1.0)
        newImage.unlockFocus()
        return newImage
#endif
    }
}
/*
 
 used by Reporting PDFBooking reiszed
 */
