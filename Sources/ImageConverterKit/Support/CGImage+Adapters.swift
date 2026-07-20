//
//  CGImage+Adapters
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 17.07.2026.
//
import ImageIO
import Foundation
import Extensions
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Data {
    /// Adapter to return an CGImage for Data on all platforms
    internal var platformCGImage: CGImage? {
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

extension CGImage {
    internal var platformImage: PlatformImage {
        #if canImport(UIKit)
        UIImage(
            cgImage: self,
            scale: 1,
            orientation: .up
        )
        #elseif canImport(AppKit)
        NSImage(
            cgImage: self,
            size: NSSize(
                width: width,
                height: height
            )
        )
        #endif
    }
}
