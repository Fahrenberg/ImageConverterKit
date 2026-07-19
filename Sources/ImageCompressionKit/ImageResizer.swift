//
//  ImageResizer.swift
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 17.07.2026.
//
import Foundation
import UniformTypeIdentifiers
import ImageIO
import Extensions
import OSLog


public enum ImageAlignment {
    case left
    case center
    case right
}

public enum ImageResizer {
    public static func resizedData(
    from imageData: Data,
    to targetSize: CGSize,
    alignment: ImageAlignment = .center
    ) -> Data? {
        guard
            let imageType = imageData.imageType,
            let cgImage = imageData.platformCGImage,
            let resizedCGImage = resizedCGImage(
                from: cgImage,
                toPixelSize: targetSize,
                alignment: alignment
            )
        else {
            return nil
        }

        return ImageConverter.convertData(
            from: resizedCGImage,
            type: imageType
        )
    }

    public static func resizedCGImage(
        from image: CGImage,
        toPixelSize pixelSize: CGSize,
        alignment: ImageAlignment
    ) -> CGImage? {
        let canvasWidth = Int(pixelSize.width.rounded())
        let canvasHeight = Int(pixelSize.height.rounded())

        guard canvasWidth > 0, canvasHeight > 0 else {
            return nil
        }

        let canvasSize = CGSize(
            width: canvasWidth,
            height: canvasHeight
        )

        let sourceSize = CGSize(
            width: image.width,
            height: image.height
        )

        let scale = min(
            canvasSize.width / sourceSize.width,
            canvasSize.height / sourceSize.height
        )

        let scaledSize = CGSize(
            width: sourceSize.width * scale,
            height: sourceSize.height * scale
        )

        let xOffset: CGFloat

        switch alignment {
        case .left:
            xOffset = 0

        case .center:
            xOffset = (canvasSize.width - scaledSize.width) / 2

        case .right:
            xOffset = canvasSize.width - scaledSize.width
        }

        let drawingRect = CGRect(
            x: xOffset,
            y: (canvasSize.height - scaledSize.height) / 2,
            width: scaledSize.width,
            height: scaledSize.height
        )

        let colorSpace =
            image.colorSpace
            ?? CGColorSpace(name: CGColorSpace.sRGB)
            ?? CGColorSpaceCreateDeviceRGB()

        let bitmapInfo: CGBitmapInfo = [
            .byteOrder32Big,
            CGBitmapInfo(
                rawValue: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        ]
        
        guard let context = CGContext(
            data: nil,
            width: canvasWidth,
            height: canvasHeight,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }

        context.interpolationQuality = .high
        context.draw(image, in: drawingRect)

        return context.makeImage()
    }
}
