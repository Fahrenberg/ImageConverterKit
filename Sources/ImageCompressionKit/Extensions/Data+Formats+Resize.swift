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

//MARK: Converting  & Quality
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

    public func pngData() -> Data? {
        let pngData =  ImageConverter.convertData(
            from: self,
            type: .png
        )
        return pngData
    }
    
    
}

// MARK: Target Size - keep ImageType
extension Data {
    public func changeImageDataSize(to askedMaxSize: Int) -> Data? {
        guard let imageType else { return nil }
        return ImageConverter.convertData(from: self, to: imageType, with: askedMaxSize)
    }
}

//MARK: Converting & TargetSize
extension Data {
    public func heicData(askedMaxSize: Int) -> Data? {
        return ImageConverter.convertData(from: self, to: .heic, with: askedMaxSize)
    }

    public func jpegData(askedMaxSize: Int) -> Data? {
        return ImageConverter.convertData(from: self, to: .jpeg, with: askedMaxSize)
    }
}


//MARK: Resize
extension Data {
    public func resizeImage(to targetSize: CGSize,
                            background: ImageConverter.ImageBackground = ImageConverter.defaultBackground
    ) -> Data? {
        return ImageConverter.resizedData(from: self, to: targetSize, background: background)
    }
    
}

