//
//  Data+ResizeTests.swift
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 19.07.2026.
//

import CoreGraphics
import ImageIO
import OSLog
import Testing
import UniformTypeIdentifiers

import Extensions

@testable import ImageCompressionKit

struct ImageDataResizeTests {
    
 
    @Test func halvesJPGImageSize() throws {
        let originalData = try #require(
            TestImage.data(size: .JPG_Scan)
        )
        let originalCGImage = try #require(
            originalData.platformCGImage
        )
        let originalSize = originalCGImage.pixelSize

        let targetSize = originalSize * 0.5

        let resizedImageData = try #require(
            originalData.resizeImageData(to: targetSize)
        )

        #expect(resizedImageData.imageType == originalData.imageType)

        let resultCGImage = try #require(
            resizedImageData.platformCGImage
        )

        #expect(resultCGImage.pixelSize == targetSize)
    }

    @Test func doublesJPGImageSize() throws {
        let originalData = try #require(
            TestImage.data(size: .JPG_Scan)
        )
        let originalCGImage = try #require(
            originalData.platformCGImage
        )
        let originalSize = originalCGImage.pixelSize

        let targetSize = originalSize * 2

        let resizedImageData = try #require(
            originalData.resizeImageData(to: targetSize)
        )

        #expect(resizedImageData.imageType == originalData.imageType)

        let resultCGImage = try #require(
            resizedImageData.platformCGImage
        )

        #expect(resultCGImage.pixelSize == targetSize)
    }

    @Test
    func alignmentLeftImageResized() throws {
        try assertImageAlignment(.left)
    }

    @Test
    func alignmentRightImageResized() throws {
        try assertImageAlignment(.right)
    }
    
    // MARK: - Exact rendering tests

    @Test
    func rendersExactWhiteBackgroundToPNG() throws {
        let sourceImage = try #require(
            makeSRGBImage(
                width: 100,
                height: 100
            )
        )

        let sourceSize = sourceImage.pixelSize

        let targetSize = CGSize(
            width: sourceSize.width * 2,
            height: sourceSize.height
        )

        let renderedCGImage = try #require(
            ImageConverter.resizedCGImage(
                from: sourceImage,
                toPixelSize: targetSize,
                background: .white
            )
        )

        let pngData = try #require(
            ImageConverter.convertData(
                from: renderedCGImage,
                type: .png
            )
        )

        let decodedPNGImage = try #require(
            pngData.platformCGImage
        )

        let samplePoint = try #require(
            paddingSamplePoint(
                imageSize: sourceSize,
                canvasSize: targetSize
            )
        )

        let actualColor = try #require(
            decodedPNGImage.rgbaColor(
                at: samplePoint
            )
        )

        #expect(
            actualColor == RGBAColor(
                red: 255,
                green: 255,
                blue: 255,
                alpha: 255
            )
        )
    }

    @Test
    func rendersExactOliveBackgroundToPNG() throws {
        let sourceImage = try #require(
            makeSRGBImage(
                width: 100,
                height: 100
            )
        )

        let sourceSize = sourceImage.pixelSize

        let targetSize = CGSize(
            width: sourceSize.width * 2,
            height: sourceSize.height
        )

        let oliveColor = try #require(
            CGColor(
                colorSpace: CGColorSpace(
                    name: CGColorSpace.sRGB
                )!,
                components: [
                    79.0 / 255.0,
                    143.0 / 255.0,
                    0,
                    1
                ]
            )
        )

        let renderedCGImage = try #require(
            ImageConverter.resizedCGImage(
                from: sourceImage,
                toPixelSize: targetSize,
                background: .color(oliveColor)
            )
        )

        let pngData = try #require(
            ImageConverter.convertData(
                from: renderedCGImage,
                type: .png
            )
        )

        #expect(pngData.imageType == .png)

        let decodedPNGImage = try #require(
            pngData.platformCGImage
        )

        let samplePoint = try #require(
            paddingSamplePoint(
                imageSize: sourceSize,
                canvasSize: targetSize
            )
        )

        let actualColor = try #require(
            decodedPNGImage.rgbaColor(
                at: samplePoint
            )
        )

        #expect(
            actualColor == RGBAColor(
                red: 79,
                green: 143,
                blue: 0,
                alpha: 255
            )
        )
    }

// MARK: - JPEG integration tests

    @Test func preservesWhiteBackgroundApproximatelyWhenEncodingJPG() throws {
        let originalData = try #require(
            TestImage.data(size: .JPG_Scan)
        )
        let originalCGImage = try #require(
            originalData.platformCGImage
        )
        let originalSize = originalCGImage.pixelSize

        let targetSize = CGSize(
            width: originalSize.width * 2,
            height: originalSize.height
        )

        let resizedImageData = try #require(
            originalData.resizeImageData(to: targetSize)
        )

        #expect(resizedImageData.imageType == originalData.imageType)

        let resizedCGImage = try #require(
            resizedImageData.platformCGImage
        )

        let samplePoint = try #require(
            paddingSamplePoint(
                imageSize: originalSize,
                canvasSize: targetSize
            )
        )

        let actualColor = try #require(
            resizedCGImage.rgbaColor(at: samplePoint)
        )

        #expect(
            actualColor.isApproximatelyEqual(
                to: RGBAColor(
                    red: 255,
                    green: 255,
                    blue: 255,
                    alpha: 255
                ),
                tolerance: 10
            )
        )
    }

    @Test func preservesOliveBackgroundApproximatelyWhenEncodingJPG() throws {
        let originalData = try #require(
            TestImage.data(size: .JPG_Scan)
        )
        let originalCGImage = try #require(
            originalData.platformCGImage
        )
        let originalSize = originalCGImage.pixelSize

        let targetSize = CGSize(
            width: originalSize.width * 2,
            height: originalSize.height
        )

        let oliveColor = CGColor(
            red: 79.0 / 255.0,
            green: 143.0 / 255.0,
            blue: 0,
            alpha: 1
        )

        let samplePoint = try #require(
            paddingSamplePoint(
                imageSize: originalSize,
                canvasSize: targetSize
            )
        )

        // Render once in the source image's color space.
        let renderedCGImage = try #require(
            ImageConverter.resizedCGImage(
                from: originalCGImage,
                toPixelSize: targetSize,
                background: .color(oliveColor)
            )
        )

        // Lossless reference containing the rendered color-space result.
        let referencePNGData = try #require(
            ImageConverter.convertData(
                from: renderedCGImage,
                type: .png
            )
        )

        let referencePNGImage = try #require(
            referencePNGData.platformCGImage
        )

        let expectedColor = try #require(
            referencePNGImage.rgbaColor(at: samplePoint)
        )

        // Actual public Data resizing path, encoded back to JPEG.
        let resizedJPGData = try #require(
            originalData.resizeImageData(
                to: targetSize,
                background: .color(oliveColor)
            )
        )

        #expect(resizedJPGData.imageType == originalData.imageType)

        let resizedJPGImage = try #require(
            resizedJPGData.platformCGImage
        )

        let actualColor = try #require(
            resizedJPGImage.rgbaColor(at: samplePoint)
        )

        #expect(
            actualColor.isApproximatelyEqual(
                to: expectedColor,
                tolerance: 15
            )
        )
    }

//MARK: - Edge Cases
    @Test func returnsNilForWrongImageType() throws {
        let pdfData = try #require(
            TestImage.data(filename: "SamplePDF.pdf")
        )

        #expect(!pdfData.isImage)

        let targetSize = CGSize(
            width: 2_000,
            height: 1_000
        )

        let resizedPDFData = pdfData.resizeImageData(
            to: targetSize
        )

        #expect(resizedPDFData == nil)
    }
    
    @Test(
        arguments: [
            CGSize(width: 0, height: 100),
            CGSize(width: 100, height: 0),
            CGSize(width: 0, height: 0),
            CGSize(width: -100, height: 100),
            CGSize(width: 100, height: -100)
        ]
    )
    func returnsNilForInvalidTargetSize(
        targetSize: CGSize
    ) throws {
        let originalData = try #require(
            TestImage.data(size: .JPG_Scan)
        )

        let resizedData = originalData.resizeImageData(
            to: targetSize
        )

        #expect(resizedData == nil)
    }
    
    @Test func preservesTransparentPaddingWhenEncodingPNG() throws {
        let sourceImage = try #require(
            makeSRGBImage(
                width: 100,
                height: 100
            )
        )

        let sourceData = try #require(
            ImageConverter.convertData(
                from: sourceImage,
                type: .png
            )
        )

        let targetSize = CGSize(
            width: 200,
            height: 100
        )

        let resizedData = try #require(
            sourceData.resizeImageData(
                to: targetSize,
                background: .transparent
            )
        )

        #expect(resizedData.imageType == .png)

        let resizedImage = try #require(
            resizedData.platformCGImage
        )

        let samplePoint = try #require(
            paddingSamplePoint(
                imageSize: sourceImage.pixelSize,
                canvasSize: targetSize
            )
        )

        let actualColor = try #require(
            resizedImage.rgbaColor(
                at: samplePoint
            )
        )

        #expect(actualColor.alpha == 0)
    }
    
    @Test func preservesPixelDimensionsWhenTargetSizeEqualsSourceSize() throws {
        let originalData = try #require(
            TestImage.data(size: .JPG_Scan)
        )

        let originalImage = try #require(
            originalData.platformCGImage
        )

        let resizedData = try #require(
            originalData.resizeImageData(
                to: originalImage.pixelSize
            )
        )

        let resizedImage = try #require(
            resizedData.platformCGImage
        )

        #expect(
            resizedImage.pixelSize ==
            originalImage.pixelSize
        )

        #expect(
            resizedData.imageType ==
            originalData.imageType
        )
    }
    
    @Test func returnsNilForCorruptedImageData() {
        let corruptedJPGData = Data([
            0xFF,
            0xD8,
            0xFF,
            0xE0,
            0x00,
            0x10
        ])

        let result = corruptedJPGData.resizeImageData(
            to: CGSize(
                width: 100,
                height: 100
            )
        )

        #expect(result == nil)
    }
    
}

// MARK: - Test helpers

private struct RGBAColor: Equatable {
    let red: UInt8
    let green: UInt8
    let blue: UInt8
    let alpha: UInt8

    func isApproximatelyEqual(
        to expected: RGBAColor,
        tolerance: UInt8
    ) -> Bool {
        componentIsApproximatelyEqual(
            red,
            expected.red,
            tolerance: tolerance
        ) &&
        componentIsApproximatelyEqual(
            green,
            expected.green,
            tolerance: tolerance
        ) &&
        componentIsApproximatelyEqual(
            blue,
            expected.blue,
            tolerance: tolerance
        ) &&
        componentIsApproximatelyEqual(
            alpha,
            expected.alpha,
            tolerance: tolerance
        )
    }

    private func componentIsApproximatelyEqual(
        _ value: UInt8,
        _ expected: UInt8,
        tolerance: UInt8
    ) -> Bool {
        abs(Int(value) - Int(expected)) <= Int(tolerance)
    }
}

private extension CGImage {

    var pixelSize: CGSize {
        CGSize(
            width: width,
            height: height
        )
    }

    func rgbaColor(
        at point: CGPoint
    ) -> RGBAColor? {
        let x = Int(point.x)
        let y = Int(point.y)

        guard
            x >= 0,
            x < width,
            y >= 0,
            y < height
        else {
            return nil
        }

        var pixel = [UInt8](
            repeating: 0,
            count: 4
        )

        guard let colorSpace = CGColorSpace(
            name: CGColorSpace.sRGB
        ) else {
            return nil
        }

        let bitmapInfo =
            CGImageAlphaInfo.premultipliedLast.rawValue |
            CGBitmapInfo.byteOrder32Big.rawValue

        guard let context = CGContext(
            data: &pixel,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }

        context.interpolationQuality = .none
        context.translateBy(
            x: -CGFloat(x),
            y: -CGFloat(y)
        )

        context.draw(
            self,
            in: CGRect(
                x: 0,
                y: 0,
                width: width,
                height: height
            )
        )

        return RGBAColor(
            red: pixel[0],
            green: pixel[1],
            blue: pixel[2],
            alpha: pixel[3]
        )
    }

    func encodedData(
        as type: UTType
    ) -> Data? {
        let output = NSMutableData()

        guard let destination = CGImageDestinationCreateWithData(
            output,
            type.identifier as CFString,
            1,
            nil
        ) else {
            return nil
        }

        CGImageDestinationAddImage(
            destination,
            self,
            nil
        )

        guard CGImageDestinationFinalize(destination) else {
            return nil
        }

        return output as Data
    }
}

private func paddingSamplePoint(
    imageSize: CGSize,
    canvasSize: CGSize
) -> CGPoint? {
    guard
        imageSize.width > 0,
        imageSize.height > 0,
        canvasSize.width > 0,
        canvasSize.height > 0
    else {
        return nil
    }

    let scale = min(
        canvasSize.width / imageSize.width,
        canvasSize.height / imageSize.height
    )

    let drawnSize = CGSize(
        width: imageSize.width * scale,
        height: imageSize.height * scale
    )

    let horizontalPadding = (
        canvasSize.width - drawnSize.width
    ) / 2

    let verticalPadding = (
        canvasSize.height - drawnSize.height
    ) / 2

    if horizontalPadding >= 2 {
        return CGPoint(
            x: horizontalPadding / 2,
            y: canvasSize.height / 2
        )
    }

    if verticalPadding >= 2 {
        return CGPoint(
            x: canvasSize.width / 2,
            y: verticalPadding / 2
        )
    }

    return nil
}

private func assertImageAlignment(
    _ alignment: ImageConverter.ImageAlignment
) throws {
    let sourceImage = try #require(
        makeSRGBImage(
            width: 100,
            height: 100
        )
    )

    let sourceData = try #require(
        ImageConverter.convertData(
            from: sourceImage,
            type: .png
        )
    )

    let decodedSourceImage = try #require(
        sourceData.platformCGImage
    )

    let expectedImageColor = try #require(
        decodedSourceImage.rgbaColor(
            at: CGPoint(
                x: decodedSourceImage.width / 2,
                y: decodedSourceImage.height / 2
            )
        )
    )

    let targetSize = CGSize(
        width: 200,
        height: 100
    )

    let resizedData = try #require(
        sourceData.resizeImageData(
            to: targetSize,
            alignment: alignment,
            background: .white
        )
    )

    let resizedImage = try #require(
        resizedData.platformCGImage
    )

    let samplePoints = alignmentSamplePoints(
        alignment: alignment,
        canvasSize: targetSize
    )

    let actualImageColor = try #require(
        resizedImage.rgbaColor(
            at: samplePoints.image
        )
    )

    let actualPaddingColor = try #require(
        resizedImage.rgbaColor(
            at: samplePoints.padding
        )
    )

    #expect(
        actualImageColor == expectedImageColor
    )

    #expect(
        actualPaddingColor == RGBAColor(
            red: 255,
            green: 255,
            blue: 255,
            alpha: 255
        )
    )
}

private func alignmentSamplePoints(
    alignment: ImageConverter.ImageAlignment,
    canvasSize: CGSize
) -> (
    image: CGPoint,
    padding: CGPoint
) {
    let leftPoint = CGPoint(
        x: canvasSize.width * 0.25,
        y: canvasSize.height * 0.5
    )

    let rightPoint = CGPoint(
        x: canvasSize.width * 0.75,
        y: canvasSize.height * 0.5
    )

    switch alignment {
    case .left:
        return (
            image: leftPoint,
            padding: rightPoint
        )

    case .right:
        return (
            image: rightPoint,
            padding: leftPoint
        )

    case .center:
        return (
            image: CGPoint(
                x: canvasSize.width * 0.5,
                y: canvasSize.height * 0.5
            ),
            padding: leftPoint
        )
    }
}


private func makeSRGBImage(
    width: Int,
    height: Int
) -> CGImage? {
    guard
        width > 0,
        height > 0,
        let colorSpace = CGColorSpace(
            name: CGColorSpace.sRGB
        )
    else {
        return nil
    }

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
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: bitmapInfo.rawValue
    ) else {
        return nil
    }

    context.setFillColor(
        CGColor(
            gray: 0.5,
            alpha: 1
        )
    )

    context.fill(
        CGRect(
            x: 0,
            y: 0,
            width: width,
            height: height
        )
    )

    return context.makeImage()
}
