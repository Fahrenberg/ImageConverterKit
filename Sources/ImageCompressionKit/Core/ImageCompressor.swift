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
        compressionQuality: CGFloat = 0.75
    ) -> Data? {
        compressedData(
            from: imageData,
            type: AVFileType.heic as CFString,
            compressionQuality: compressionQuality
        )
    }

    public static func jpegData(
        from imageData: Data,
        compressionQuality: CGFloat = 0.75
    ) -> Data? {
        compressedData(
            from: imageData,
            type: UTType.jpeg.identifier as CFString,
            compressionQuality: compressionQuality
        )
    }

    private static func compressedData(
           from imageData: Data,
           type: CFString,
           compressionQuality: CGFloat
       ) -> Data? {
           let quality = min(max(compressionQuality, 0), 1)
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

           let options: NSDictionary = [
               kCGImageDestinationLossyCompressionQuality: quality
           ]
           CGImageDestinationAddImage(destination, cgImage, options)
           guard CGImageDestinationFinalize(destination) else {
               return nil
           }
           return output as Data
       }
}
