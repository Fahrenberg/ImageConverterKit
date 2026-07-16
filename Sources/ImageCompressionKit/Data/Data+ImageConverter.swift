//
//  Data+ImageConverter.swift
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 13.07.2026.
//

import OSLog
import Extensions
import ImageIO
import UniformTypeIdentifiers

//MARK: HEIC
extension Data {
    public func heicData(quality: Double = ImageConverter.defaultHEICQuality) -> Data? {
        // HEIC specific, compressionQuality must be < 1, precondition stops runtime, assume programmer error
        precondition(
            (0..<1).contains(quality),
            "heic compression quality must be between 0 and lower than 1."
        )
        guard quality < 1 else
        { return nil }
        guard let heicData = ImageConverter.convertData(
            from: self,
            type: .heic,
            quality: quality
        )
        else { return nil}
        return heicData.count <= self.count ? heicData : nil
    }
    
    public func heicData(askedMaxSize: Int) -> Data? {
        return ImageConverter.convertData(from: self, to: .heic, with: askedMaxSize)
    }
}

//MARK: JPEG
extension Data {
    public  func jpegData(quality: Double = ImageConverter.defaultJPEGQuality) -> Data? {
        // CompressionQuality must be <= 1, precondition stops runtime, assume programmer error
        precondition(
            (0...1).contains(quality),
            "jpegData compression quality must be between 0 and 1."
        )
        guard let jpegData = ImageConverter.convertData(
            from: self,
            type: .jpeg,
            quality: quality
        )
        else { return nil }
        return jpegData.count <= self.count ? jpegData : nil
    }
}

//MARK: PNG
extension Data {
    public func pngData() -> Data? {
        let pngData =  ImageConverter.convertData(
            from: self,
            type: .png
        )
        return pngData
    }
    
    
}

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
