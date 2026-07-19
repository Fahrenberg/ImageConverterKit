//
//  PlatformImage Image Adapters.swift
//  ImageCompressionKit
//
//  Adapter for a convience function to directly convert a  PlatformImage to image data using heic, png or jpeg conversion/compression
//  Created by Jean-Nicolas on 17.06.2026.
//

import OSLog
import Extensions
import ImageIO
import UniformTypeIdentifiers

//MARK: Quality
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
    
    public func jpgData(quality: Double = ImageConverter.defaultJPEGQuality) -> Data? {
        guard let cgImage = self.platformCGImage,
              let data = ImageConverter.convertData(from: cgImage,
                                                    type: .png),
              let jpegData = data.jpegData(quality: quality)
        else { return nil }
        return jpegData
    }
    
// Extensions offers an pngData() converter, remove first from Extension
//    public func pngData() -> Data? {
//        let data = Data()
//        return data
//    }
}


//MARK: TargetSize
extension PlatformImage {
    
    public func heicData(askedMaxSize: Int) -> Data? {
        guard let cgImage = self.platformCGImage,
              let data = ImageConverter.convertData(from: cgImage,
                                                    type: .png),
              let heicData = data.heicData(askedMaxSize: askedMaxSize)
        else { return nil }
        return heicData
    }
    
    public func jpgData(askedMaxSize: Int) -> Data? {
        guard let cgImage = self.platformCGImage,
              let data = ImageConverter.convertData(from: cgImage,
                                                    type: .png),
              let jpegData = data.jpegData(askedMaxSize: askedMaxSize)
        else { return nil }
        return jpegData
    }
}
