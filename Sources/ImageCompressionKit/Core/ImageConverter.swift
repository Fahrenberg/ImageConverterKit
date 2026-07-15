//
//  ImageCompressor.swift - Image compression
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 17.06.2026.
//

import Foundation
import UniformTypeIdentifiers
import ImageIO
import Extensions
import AVFoundation

public enum ImageConverter {
    public static let defaultHEICQuality: Double = 0.75
    public static let defaultJPEGQuality: Double = 0.65
    
    /// Converts image data to the specified image format using ImageIO.
    /// 
    /// The image is decoded from `imageData` and re-encoded using the destination
    /// image type. For lossy formats (such as HEIC and JPEG), an optional
    /// `quality` in the range `0...1` may be supplied.
    ///
    /// For lossy formats (such as HEIC and JPEG), an optional compression
    /// `quality` in the range `0...1` may be supplied:
    ///    - 0 means max compression and lowest quality
    ///    - 1 means best quality but low or none compression.
    ///
    /// If the destination format does not benefit from an alpha channel, any
    /// unused alpha channel is removed before encoding to reduce file size and
    /// avoid unnecessary memory usage.
    ///
    ///
    /// - Parameters:
    ///   - imageData: The source image data.
    ///   - type: The destination image type (UTType).
    ///   - quality: The compression quality for lossy formats. Ignored
    ///     for lossless formats such as PNG.
    ///
    /// - Returns: The converted image data, or `nil` if the image could not be
    ///   decoded or encoded.
    internal static func convertData(
        from imageData: Data,
        type: UTType,
        quality: CGFloat? = nil
    ) -> Data? {
        guard let cgImage = imageData.platformCGImage
        else { return nil }
        return convertData(from: cgImage, type: type, quality: quality)
    }
    
    /// Converts cgImage data to the specified image format using ImageIO.
    ///
    /// The image is decoded from `cgImage` and re-encoded using the destination
    /// image type.
    ///
    /// For lossy formats (such as HEIC and JPEG), an optional compression
    /// `quality` in the range `0...1` may be supplied:
    ///    - 0 means max compression and lowest quality
    ///    - 1 means best quality but low or none compression.
    ///
    /// If the destination format does not benefit from an alpha channel, any
    /// unused alpha channel is removed before encoding to reduce file size and
    /// avoid unnecessary memory usage.
    ///
    /// - Parameters:
    ///   - cgImage: The source CGImage.
    ///   - type: The destination image type (UTType).
    ///   - quality: The compression quality for lossy formats. Ignored
    ///     for lossless formats such as PNG.
    ///
    /// - Returns: The converted image data, or `nil` if the image could not be
    ///   decoded or encoded.
    internal static func convertData(
        from cgImage: CGImage,
        type: UTType,
        quality: CGFloat? = nil
    ) -> Data? {
        let quality = quality.map { min(max($0, 0), 1) }
        let image: CGImage = shouldRemoveAlpha(for: type)
            ? (cgImage.removingAlphaIfNeeded() ?? cgImage)
            : cgImage

        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(output,type.identifier as CFString,1,nil)
        else { return nil }

        let options: NSDictionary? = quality.map {
            [kCGImageDestinationLossyCompressionQuality: $0]
        }

        CGImageDestinationAddImage(destination, image, options)

        guard CGImageDestinationFinalize(destination)
        else { return nil  }

        return output as Data
    }
    
    internal static func shouldRemoveAlpha(for type: UTType) -> Bool {
        switch type {
        case UTType.jpeg,
            UTType.heic,
            UTType.heif :
            return true
        default:
            return false
        }
    }
    
}

fileprivate extension CGImage {
    /// Returns a copy of the image without an alpha channel when the image is
    /// fully opaque.
    ///
    /// Some images are decoded with an alpha channel even though all pixels are
    /// opaque. Removing the unused alpha channel before encoding to formats such
    /// as JPEG or HEIC reduces file size, lowers memory usage when decoding, and
    /// avoids ImageIO warnings about unnecessary alpha channels.
    ///
    /// - Returns: A new image without an alpha channel, or `self` if no alpha
    ///   channel is present. Returns `nil` if the image cannot be redrawn.
    func removingAlphaIfNeeded() -> CGImage? {
        guard alphaInfo != .none,
              alphaInfo != .noneSkipLast,
              alphaInfo != .noneSkipFirst
        else {
            return self
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ) else {
            return nil
        }

        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        return context.makeImage()
    }
}


/*
extension ImageConverter
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
*/
