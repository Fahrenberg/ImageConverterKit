//
//  ImageType.swift
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 20.06.2026.
//
import Foundation
import ImageIO
import UniformTypeIdentifiers



/// Convenience properties for checking common image Uniform Type Identifiers.
///
/// These helpers provide a more expressive alternative to calling
/// `conforms(to:)` directly when working with `UTType` values.
extension UTType {

    /// A Boolean value indicating whether the type represents an image.
    ///
    /// Returns `true` if the receiver conforms to ``UTType/image``,
    /// including formats such as JPEG, PNG, HEIC, GIF, TIFF, RAW, and
    /// other image types.
    public var isImage: Bool {
        conforms(to: .image)
    }

    /// A Boolean value indicating whether the type represents a HEIC or HEIF image.
    ///
    /// Returns `true` if the receiver conforms to either ``UTType/heic``
    /// or ``UTType/heif``.
    public var isHEICImage: Bool {
        conforms(to: .heic) || conforms(to: .heif)
    }

    /// A Boolean value indicating whether the type represents a JPEG image.
    ///
    /// Returns `true` if the receiver conforms to ``UTType/jpeg``.
    public var isJPGImage: Bool {
        conforms(to: .jpeg)
    }

    /// A Boolean value indicating whether the type represents a PNG image.
    ///
    /// Returns `true` if the receiver conforms to ``UTType/png``.
    public var isPNGImage: Bool {
        conforms(to: .png)
    }
    
    internal var shouldRemoveAlpha: Bool {
        switch self {
        case UTType.jpeg,
            UTType.heic,
            UTType.heif :
            return true
        default:
            return false
        }
    }
}

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
