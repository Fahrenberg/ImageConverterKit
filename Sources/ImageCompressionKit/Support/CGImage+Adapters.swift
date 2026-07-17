//
//  Data+CGImage.swift
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 17.07.2026.
//
import ImageIO
import Foundation
import Extensions

internal extension Data {
    /// Adapter to return an CGImage for Data on all platforms
    var platformCGImage: CGImage? {
        guard let source = CGImageSourceCreateWithData(self as CFData, nil),
              CGImageSourceGetCount(source) > 0,
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else { return nil }
        
        return cgImage
    }
}


internal extension PlatformImage {
    /// Adapter to return an CGImage for all apple platforms
    var platformCGImage: CGImage? {
        #if canImport(UIKit)
        cgImage
        #elseif canImport(AppKit)
        cgImage(forProposedRect: nil, context: nil, hints: nil)
        #endif
    }
}
