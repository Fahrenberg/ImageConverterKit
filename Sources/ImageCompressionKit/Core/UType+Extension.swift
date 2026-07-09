//
//  UType+Extension.swift
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 09.07.2026.
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
}
