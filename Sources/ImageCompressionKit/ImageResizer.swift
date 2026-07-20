//
//  ImageResizer.swift
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 17.07.2026.
//

import CoreGraphics
import Foundation
import Extensions

public enum ImageResizer {
    public static let defaultAlignment: ImageAlignment = .center
    public static let defaultBackground: ImageBackground = .white
}

public enum ImageAlignment {
    case left
    case center
    case right
}

public enum ImageBackground {
    case transparent
    case white
    case black
    case color(CGColor)

    internal var cgColor: CGColor? {
        switch self {
        case .transparent:
            nil

        case .white:
            CGColor(
                gray: 1,
                alpha: 1
            )

        case .black:
            CGColor(
                gray: 0,
                alpha: 1
            )

        case .color(let color):
            color
        }
    }
}

extension ImageResizer {
    static func resizedData(
        from imageData: Data,
        to targetSize: CGSize,
        alignment: ImageAlignment = defaultAlignment,
        background: ImageBackground = defaultBackground
    ) -> Data? {
        guard
            let imageType = imageData.imageType,
            let cgImage = imageData.platformCGImage,
            let resizedCGImage = resizedCGImage(
                from: cgImage,
                toPixelSize: targetSize,
                alignment: alignment,
                background: background
            )
        else {
            return nil
        }

        return ImageConverter.convertData(
            from: resizedCGImage,
            type: imageType
        )
    }

    static func resizedCGImage(
        from image: CGImage,
        toPixelSize pixelSize: CGSize,
        alignment: ImageAlignment = defaultAlignment,
        background: ImageBackground = defaultBackground
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
            xOffset = (
                canvasSize.width - scaledSize.width
            ) / 2

        case .right:
            xOffset = canvasSize.width - scaledSize.width
        }

        let yOffset = (
            canvasSize.height - scaledSize.height
        ) / 2

        let drawingRect = CGRect(
            x: xOffset,
            y: yOffset,
            width: scaledSize.width,
            height: scaledSize.height
        )

        let canvasRect = CGRect(
            origin: .zero,
            size: canvasSize
        )

        let colorSpace =
            image.colorSpace
            ?? CGColorSpace(name: CGColorSpace.sRGB)
            ?? CGColorSpaceCreateDeviceRGB()

        let bitmapInfo: CGBitmapInfo = [
            .byteOrder32Big,
            CGBitmapInfo(
                rawValue:
                    CGImageAlphaInfo
                    .premultipliedLast
                    .rawValue
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

        draw(
            background,
            in: context,
            canvasRect: canvasRect
        )

        context.interpolationQuality = .high
        context.draw(
            image,
            in: drawingRect
        )

        return context.makeImage()
    }

    private static func draw(
        _ background: ImageBackground,
        in context: CGContext,
        canvasRect: CGRect
    ) {
        guard let backgroundColor = background.cgColor else {
            context.clear(canvasRect)
            return
        }

        context.setFillColor(backgroundColor)
        context.fill(canvasRect)
    }
}
