//
//  CGImage+Alpha.swift
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 17.07.2026.
//

import Foundation
import UniformTypeIdentifiers
import ImageIO
import Extensions
import OSLog

internal extension CGImage {
    /// Returns a copy of the image without an alpha channel when the image is
    /// fully opaque.
    ///
    /// Some images are decoded with an alpha channel even though all pixels are
    /// opaque. Removing the unused alpha channel before encoding to formats such
    /// as JPEG or HEIC reduces file size, lowers memory usage when decoding, and
    /// avoids ImageIO warnings about unnecessary alpha channels.
    ///
    /// - Returns: A new image without an alpha channel, or `self` if no alpha
    ///   channel is present. Returns `nil` if the image cannot be redrawn.
    func removingAlphaIfNeeded() -> CGImage? {
        guard alphaInfo != .none,
              alphaInfo != .noneSkipLast,
              alphaInfo != .noneSkipFirst
        else {
            return self
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ) else {
            return nil
        }
        
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        return context.makeImage()
    }
}
