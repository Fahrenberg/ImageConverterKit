//
//  PlatformImage Converter Adapter.swift
//  ImageCompressionKit
//
//  Adapter for a convience function to directly convert a  PlatformImage to image data using heic, png or jpeg conversion/compression
//  Created by Jean-Nicolas on 17.06.2026.
//

import OSLog
import Extensions
import ImageIO
import UniformTypeIdentifiers

extension PlatformImage {
    /// HEIC Image Compression (more efficient, slower)
    ///
    /// Use it only with [supported devices for HEIC](https://support.apple.com/en-us/HT207022)
    public func heicData(quality: Double = ImageConverter.defaultHEICQuality) -> Data? {
        guard let cgImage = self.platformCGImage,
              let data = ImageConverter.convertData(from: cgImage,
                                                    type: .png),
              let heicData = data.heicData(quality: quality)
        else { return nil }
        return heicData
    }
    
    public func heicData(askedMaxSize: Int) -> Data? {
        guard let cgImage = self.platformCGImage,
              let data = ImageConverter.convertData(from: cgImage,
                                                    type: .png),
              let heicData = data.heicData(askedMaxSize: askedMaxSize)
        else { return nil }
        return heicData
    }

    public func jpgData(quality: Double = ImageConverter.defaultJPEGQuality) -> Data? {
        guard let cgImage = self.platformCGImage,
              let data = ImageConverter.convertData(from: cgImage,
                                                    type: .png),
              let jpegData = data.jpegData(quality: quality)
        else { return nil }
        return jpegData
    }
    
    
    public func jpgData(askedMaxSize: Int) -> Data? {
        guard let cgImage = self.platformCGImage,
              let data = ImageConverter.convertData(from: cgImage,
                                                    type: .png),
              let jpegData = data.jpegData(askedMaxSize: askedMaxSize)
        else { return nil }
        return jpegData
    }
    
    // Extensions offers an pngData() converter, remove first from Extension
//    public func pngData() -> Data? {
//        let data = Data()
//        return data
//    }
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



