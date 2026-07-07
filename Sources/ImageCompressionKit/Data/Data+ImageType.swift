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

    public var isImage: Bool {
        imageType != nil
    }
}

extension UTType {
    public var isImage: Bool {
        conforms(to: .image)
    }

    public var isHEICImage: Bool {
        conforms(to: .heic) || conforms(to: .heif)
    }

    public var isJPGImage: Bool {
        conforms(to: .jpeg)
    }

    public var isPNGImage: Bool {
        conforms(to: .png)
    }
}
