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
    public static let defaultHEICCompression: Double = 0.75
    public static func heicData(
        from imageData: Data,
        compressionQuality: Double = defaultHEICCompression
    ) -> Data? {
        // HEIC specific, compressionQuality must be < 1, precondition stops runtime, assume programmer error
        precondition(
                (0..<1).contains(compressionQuality),
                "heic compressionQuality must be between 0 and lower than 1."
            )
        guard compressionQuality < 1 else
        { return nil }
        guard let heicData = convertData(
            from: imageData,
            type: AVFileType.heic as CFString,
            compressionQuality: compressionQuality
            )
        else { return nil}
        return heicData.count <= imageData.count ? heicData : nil
    }

    public static let defaultJPEGCompression: Double = 0.65
    public static func jpegData(
        from imageData: Data,
        compressionQuality: Double = defaultJPEGCompression
    ) -> Data? {
        // CompressionQuality must be <= 1, precondition stops runtime, assume programmer error
        precondition(
                (0...1).contains(compressionQuality),
                "jpegData compressionQuality must be between 0 and 1."
            )
        guard let jpegData = convertData(
            from: imageData,
            type: UTType.jpeg.identifier as CFString,
            compressionQuality: compressionQuality
            )
        else { return nil }
        return jpegData.count <= imageData.count ? jpegData : nil
    }

    public static func pngData(from imageData: Data) -> Data? {
       let pngData =  convertData(
            from: imageData,
            type: UTType.png.identifier as CFString
        )
        return pngData
    }
    /// Converts image data to the specified image format using ImageIO.
    ///
    /// The image is decoded from `imageData` and re-encoded using the destination
    /// image type. For lossy formats (such as HEIC and JPEG), an optional
    /// `compressionQuality` in the range `0...1` may be supplied.
    ///
    /// If the destination format does not benefit from an alpha channel, any
    /// unused alpha channel is removed before encoding to reduce file size and
    /// avoid unnecessary memory usage.
    ///
    /// - Parameters:
    ///   - imageData: The source image data.
    ///   - type: The destination image type (UTType or AVFileType identifier).
    ///   - compressionQuality: The compression quality for lossy formats. Ignored
    ///     for lossless formats such as PNG.
    /// - Returns: The converted image data, or `nil` if the image could not be
    ///   decoded or encoded.
    internal static func convertData(
        from imageData: Data,
        type: CFString,
        compressionQuality: CGFloat? = nil
    ) -> Data? {
        let quality = compressionQuality.map { min(max($0, 0), 1) }

        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              CGImageSourceGetCount(source) > 0,
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else {
            return nil
        }

        let image: CGImage = shouldRemoveAlpha(for: type)
            ? (cgImage.removingAlphaIfNeeded() ?? cgImage)
            : cgImage

        let output = NSMutableData()

        guard let destination = CGImageDestinationCreateWithData(output, type, 1, nil) else {
            return nil
        }

        let options: NSDictionary? = quality.map {
            [kCGImageDestinationLossyCompressionQuality: $0]
        }

        CGImageDestinationAddImage(destination, image, options)

        guard CGImageDestinationFinalize(destination) else {
            return nil
        }

        return output as Data
    }
    
    internal static func shouldRemoveAlpha(for type: CFString) -> Bool {
        switch type as String {
        case UTType.jpeg.identifier,
            UTType.heic.identifier,
            UTType.heif.identifier :
            return true
        default:
            return false
        }
    }
    
    internal static func convertData(
        from cgImage: CGImage,
        type: CFString,
        compressionQuality: CGFloat? = nil
    ) -> Data? {
        
        let image: CGImage = shouldRemoveAlpha(for: type)
            ? (cgImage.removingAlphaIfNeeded() ?? cgImage)
            : cgImage



        let output = NSMutableData()

        guard let destination = CGImageDestinationCreateWithData(output, type, 1, nil) else {
            return nil
        }

        let options: NSDictionary? = compressionQuality.map {
            [kCGImageDestinationLossyCompressionQuality: min(max($0, 0), 1)]
        }

        CGImageDestinationAddImage(destination, image, options)

        guard CGImageDestinationFinalize(destination) else {
            return nil
        }

        return output as Data
    }
    
}

private extension CGImage {
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
