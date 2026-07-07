//
//  ImageCompressor.swift - Image compression
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 17.06.2026.
//

import Foundation
import UniformTypeIdentifiers
import ImageIO
import Extensions
import AVFoundation

public enum ImageCompressor {

    public static func heicData(
        from imageData: Data,
        compressionQuality: Double = 0.75
    ) -> Data? {
        // HEIC specific, must be less than 1
        guard compressionQuality < 1 else { return nil }
        guard let heicData = convertData(
            from: imageData,
            type: AVFileType.heic as CFString,
            compressionQuality: compressionQuality
            )
        else { return nil}
        return heicData.count <= imageData.count ? heicData : nil
    }

    public static func jpegData(
        from imageData: Data,
        compressionQuality: Double = 0.65
    ) -> Data? {
        guard let jpegData = convertData(
            from: imageData,
            type: UTType.jpeg.identifier as CFString,
            compressionQuality: compressionQuality
            )
        else { return nil }
        return jpegData.count <= imageData.count ? jpegData : nil
    }

    public static func pngData(from imageData: Data) -> Data? {
       let pngData =  convertData(
            from: imageData,
            type: UTType.png.identifier as CFString
        )
        return pngData
    }

    private static func convertData(
        from imageData: Data,
        type: CFString,
        compressionQuality: CGFloat? = nil
    ) -> Data? {
        let quality = compressionQuality.map { min(max($0, 0), 1) }
        
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              CGImageSourceGetCount(source) > 0,
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else {
            return nil
        }
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(output,type, 1, nil)
        else {
            return nil
        }

        let options: NSDictionary? = quality.map {
            [kCGImageDestinationLossyCompressionQuality: $0]
        }

        CGImageDestinationAddImage(destination, cgImage, options)
        guard CGImageDestinationFinalize(destination) else {
            return nil
        }
        
        return output as Data
    }
}
