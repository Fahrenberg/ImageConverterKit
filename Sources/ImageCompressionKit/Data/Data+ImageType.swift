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
    public var isImage: Bool {
           imageType != nil
       }

    public var isHEICImage: Bool {
        guard let imageType else { return false }

        return imageType.conforms(to: .heic)
            || imageType.conforms(to: .heif)
    }
    
    private var imageType: UTType? {
        guard
            let source = CGImageSourceCreateWithData(self as CFData, nil),
            let type = CGImageSourceGetType(source),
            let utType = UTType(type as String),
            utType.conforms(to: .image)
        else {
            return nil
        }

        return utType
    }
}
