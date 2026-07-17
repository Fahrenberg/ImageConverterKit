//
//  ImageConverter+Encoding.swift
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 17.07.2026.
//

import Foundation
import UniformTypeIdentifiers
import ImageIO
import Extensions
import OSLog

extension ImageConverter {
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
        let image: CGImage = type.shouldRemoveAlpha
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
    
   
    
}
