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
import OSLog

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


extension ImageConverter {
    /// Converts image data and searches for a compression quality whose resulting
    /// size is as close as possible to the requested size.
    ///
    /// The search assumes that increasing the quality produces larger output data.
    ///
    /// - Parameters:
    ///   - imageData: The source image data.
    ///   - type: The destination image type.
    ///   - askedMaxSize: The target data size in bytes.
    ///
    /// - Returns: Converted data within the accepted tolerance when possible.
    ///   Otherwise, returns the closest result found during the search.
    internal static func convertData(
        from imageData: Data,
        to type: UTType,
        with askedMaxSize: Int
    ) -> Data? {
        guard askedMaxSize > 0 else {
            return nil
        }

        let tolerance = 0.2
        let minimumSize = Int(
            Double(askedMaxSize) * (1.0 - tolerance)
        )
        let maximumSize = askedMaxSize

        let defaultQuality = ImageConverter.defaultHEICQuality
        let maximumQuality = 0.99
        let maxAttempts = 10

        guard let defaultData = ImageConverter.convertData(
            from: imageData,
            type: type,
            quality: defaultQuality
        ) else {
            Logger.source.debug(
                "Conversion failed for \(type.description)."
            )
            return nil
        }

        if (minimumSize...maximumSize).contains(defaultData.count) {
            logSuccessfulConversion(
                askedMaxSize: askedMaxSize,
                quality: defaultQuality,
                attempts: 1
            )

            return defaultData
        }

        var lowerQuality: Double
        var upperQuality: Double

        if defaultData.count < minimumSize {
            // The result is too small, so only search higher qualities.
            lowerQuality = defaultQuality
            upperQuality = maximumQuality
        } else {
            // The result is too large, so only search lower qualities.
            lowerQuality = 0
            upperQuality = defaultQuality
        }

        var bestResult = CompressionResult(
            data: defaultData,
            quality: defaultQuality,
            distanceFromTarget: abs(defaultData.count - askedMaxSize)
        )

        var attempts = 1

        while attempts < maxAttempts {
            attempts += 1

            let quality = (lowerQuality + upperQuality) / 2

            guard let convertedData = ImageConverter.convertData(
                from: imageData,
                type: type,
                quality: quality
            ) else {
                return nil
            }

            let dataSize = convertedData.count
            let distanceFromTarget = abs(dataSize - askedMaxSize)

            if distanceFromTarget < bestResult.distanceFromTarget {
                bestResult = CompressionResult(
                    data: convertedData,
                    quality: quality,
                    distanceFromTarget: distanceFromTarget
                )
            }

            if (minimumSize...maximumSize).contains(dataSize) {
                logSuccessfulConversion(
                    askedMaxSize: askedMaxSize,
                    quality: quality,
                    attempts: attempts
                )

                return convertedData
            }

            if dataSize < minimumSize {
                // Too small: increase quality.
                lowerQuality = quality
            } else {
                // Too large: decrease quality.
                upperQuality = quality
            }
        }

        Logger.source.warning(
            """
            Exact compression range not reached.
            Requested max. size: \(askedMaxSize.outputKBytes)
            Resulting size: \(bestResult.data.count.outputKBytes)
            Compression quality: \(bestResult.quality)
            Attempts: \(attempts)
            """
        )

        return bestResult.data
    }

    private struct CompressionResult {
        let data: Data
        let quality: Double
        let distanceFromTarget: Int
    }

    private static func logSuccessfulConversion(
        askedMaxSize: Int,
        quality: Double,
        attempts: Int
    ) {
        Logger.source.debug(
            """
            Compression completed.
            Requested size: \(askedMaxSize.outputKBytes)
            Compression quality: \(quality)
            Attempts: \(attempts)
            """
        )
    }
}
