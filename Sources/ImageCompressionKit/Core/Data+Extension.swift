//
//  Data+ImageType.swift
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 20.06.2026.
//
import Foundation
import ImageIO
import UniformTypeIdentifiers

extension Data {
    
    /// Returns the detected image type of this `Data` instance.
    ///
    /// The receiver is inspected using `ImageIO` to determine its
    /// `UTType`. If the data does not represent a supported image,
    /// `nil` is returned.
    ///
    /// This property identifies the image format (for example, JPEG,
    /// PNG, HEIC, GIF, or TIFF) without decoding the image pixels.
    ///
    /// - Returns: The detected image `UTType`, or `nil` if the data is
    ///   not a valid image.
    public var imageType: UTType? {
        guard
            let source = CGImageSourceCreateWithData(self as CFData, nil),
            let type = CGImageSourceGetType(source),
            let utType = UTType(type as String),
            utType.isImage
        else {
            return nil
        }

        return utType
    }

    /// Indicates whether this `Data` instance contains a supported image.
    ///
    /// This is a convenience property equivalent to checking
    /// `imageType != nil`.
    ///
    /// - Returns: `true` if the data represents a supported image;
    ///   otherwise, `false`.
    public var isImage: Bool {
        imageType != nil
    }
}

