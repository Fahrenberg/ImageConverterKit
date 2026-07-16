//
//  Data+ConverterTests.swift
//  ImageConversionKit
//
//  Created by Jean-Nicolas on 18.06.2026.
//

import Testing
import OSLog
import Extensions
import ImageIO
import UniformTypeIdentifiers

@testable import ImageCompressionKit

struct HEICImageDataConverterTests {
    
    @Test func convertsHEICDataUsingDefaultCompression() throws {
        for imageType in [ImageType.large, .medium, .small] {
            let originalData = try #require(TestImage.data(size: imageType))
            let heicCompressedData = try #require(originalData.heicData())

            // Check file type
            #expect(originalData.isImage)
            #expect(heicCompressedData.imageType?.isHEICImage == true)


            #expect(originalData.count > 0)
            #expect(heicCompressedData.count > 0)
            #expect(heicCompressedData.count < originalData.count)

            let compressionRatio = Double(heicCompressedData.count) / Double(originalData.count)
            #expect(
                compressionRatio < 0.75,
                "\(imageType.rawValue) compression ratio was \(compressionRatio)"
            )

            let compressionPercent = Int((compressionRatio * 100).rounded()) - 100
            Logger.test.info(
                "\(imageType.rawValue): original size: \(originalData.count.outputKBytes), heicCompressed: \(heicCompressedData.count.outputKBytes), compressionRatio: \(compressionPercent)%"
            )
            
            let originalSource = try #require(
                CGImageSourceCreateWithData(originalData as CFData, nil)
            )

            let originalImage = try #require(
                CGImageSourceCreateImageAtIndex(originalSource, 0, nil)
            )

            let heicSource = try #require(
                CGImageSourceCreateWithData(heicCompressedData as CFData, nil)
            )

            let heicImage = try #require(
                CGImageSourceCreateImageAtIndex(heicSource, 0, nil)
            )

            #expect(heicImage.width == originalImage.width)
            #expect(heicImage.height == originalImage.height)
        }
    }
    
    @Test func returnsHEICDataWithinAskedMaxSize() throws {
        for imageType in [ImageType.large, .medium, .small] {
            let askedMaxSize: Int = imageType.askedMaxSize(for: .heic)
            let originalData = try #require(TestImage.data(size: imageType))
            let heicConvertedData = try #require(originalData.heicData(askedMaxSize: askedMaxSize))

            // Check file type
            #expect(originalData.isImage)
            #expect(heicConvertedData.imageType?.isHEICImage == true)


            #expect(originalData.count > 0,  "\(imageType.rawValue)")
            #expect(heicConvertedData.count > 0,  "\(imageType.rawValue)")
            #expect(heicConvertedData.count < originalData.count,  "\(imageType.rawValue)")
            #expect(heicConvertedData.count <= askedMaxSize,  "\(imageType.rawValue)")

            let compressionRatio = Double(heicConvertedData.count) / Double(originalData.count)
            #expect(
                compressionRatio < 0.75,
                "\(imageType.rawValue) compression ratio was \(compressionRatio)"
            )

            let compressionPercent = Int((compressionRatio * 100).rounded()) - 100
            Logger.test.info(
                "\(imageType.rawValue): original size: \(originalData.count.outputKBytes), heicCompressed: \(heicConvertedData.count.outputKBytes), compressionRatio: \(compressionPercent)%"
            )
            
            let originalSource = try #require(
                CGImageSourceCreateWithData(originalData as CFData, nil),
                "\(imageType.rawValue)"
            )

            let originalImage = try #require(
                CGImageSourceCreateImageAtIndex(originalSource, 0, nil),
                "\(imageType.rawValue)"
            )

            let heicSource = try #require(
                CGImageSourceCreateWithData(heicConvertedData as CFData, nil),
                "\(imageType.rawValue)"
            )

            let heicImage = try #require(
                CGImageSourceCreateImageAtIndex(heicSource, 0, nil),
                "\(imageType.rawValue)"
            )

            #expect(heicImage.width == originalImage.width,  "\(imageType.rawValue)")
            #expect(heicImage.height == originalImage.height,  "\(imageType.rawValue)")
        }
        
    }

    @Test func returnsOriginalDataWhenAskedMaxSizeExceedsOriginal() throws {
        let originalData = try #require(TestImage.data(size: .large))
        let askedMaxSize = originalData.count + 1

        let convertedData = try #require(
            originalData.heicData(askedMaxSize: askedMaxSize)
        )

        #expect(convertedData.imageType?.isHEICImage == true)
        #expect(convertedData.count > 0)
        #expect(convertedData.count <= askedMaxSize)
    }

    @Test func returnsBestEffortWhenTargetSizeCannotBeReached() throws {
        let originalData = try #require(TestImage.data(size: .large))
        let impossibleAskedMaxSize = 1

        let convertedData = try #require(
            originalData.heicData(askedMaxSize: impossibleAskedMaxSize)
        )

        #expect(convertedData.imageType?.isHEICImage == true)
        #expect(convertedData.count > impossibleAskedMaxSize)
        #expect(convertedData.count < originalData.count)
    }

    @Test func returnsNilForZeroAskedMaxSize() throws {
        let originalData = try #require(TestImage.data(size: .large))

        let convertedData = originalData.heicData(askedMaxSize: 0)

        #expect(convertedData == nil)
    }
    
    
    
}

struct JPEGImageDataConverterTests {
    @Test func convertsJPEGDataUsingDefaultCompression() throws {
        for imageType in [ImageType.large, .medium, .small] {
            let originalData = try #require(TestImage.data(size: imageType))
            let jpegCompressedData = try #require(originalData.jpegData())

            // Check file type
            #expect(originalData.isImage)
            #expect(jpegCompressedData.imageType?.isJPGImage == true)


            #expect(originalData.count > 0)
            #expect(jpegCompressedData.count > 0)
            #expect(jpegCompressedData.count < originalData.count)

            let compressionRatio = Double(jpegCompressedData.count) / Double(originalData.count)
            #expect(
                compressionRatio < 0.85,
                "\(imageType.rawValue) compression ratio was \(compressionRatio)"
            )

            let compressionPercent = Int((compressionRatio * 100).rounded()) - 100
            Logger.test.info(
                "\(imageType.rawValue): original size: \(originalData.count.outputKBytes), jpegCompressed: \(jpegCompressedData.count.outputKBytes), compressionRatio: \(compressionPercent)%"
            )
            
            let originalSource = try #require(
                CGImageSourceCreateWithData(originalData as CFData, nil)
            )

            let originalImage = try #require(
                CGImageSourceCreateImageAtIndex(originalSource, 0, nil)
            )

            let jpegSource = try #require(
                CGImageSourceCreateWithData(jpegCompressedData as CFData, nil)
            )

            let jpegImage = try #require(
                CGImageSourceCreateImageAtIndex(jpegSource, 0, nil)
            )

            #expect(jpegImage.width == originalImage.width)
            #expect(jpegImage.height == originalImage.height)
        }
    }
    
    @Test func returnsNilWhenJPEGQualityOneProducesLargerData() throws {
        for imageType in [ImageType.medium, .small] {
            let originalData = try #require(TestImage.data(size: imageType))
            
            // Check file type
            #expect(originalData.isImage)
            // Check nil conversion for jpged if image compressed is larger than original
            let jpegCompressedData = originalData.jpegData(quality: 1.0)
            #expect(jpegCompressedData == nil, "ImageType: \(imageType.rawValue) : \(originalData.count.outputKBytes) vs compressed \(jpegCompressedData?.count.outputKBytes)")
        }
    }
    @Test func convertsLargeImageUsingJPEGQualityOne() throws {
        let originalData = try #require(TestImage.data(size: .large))

        // Check file type
        #expect(originalData.isImage)
        // large file will be compressed by jpeg converted, even with 1, so it is fine to use 1 here with jpeg
        let jpegCompressedData = originalData.jpegData(quality: 1.0)
        #expect(jpegCompressedData != nil, "ImageType: \(ImageType.large.rawValue) : \(originalData.count.outputKBytes) vs compressed \(jpegCompressedData?.count.outputKBytes)")
        
    }
    
}

struct PNGImageDataConverterTests {
    @Test func preservesImageDimensionsWhenConvertingToPNG() throws {
        for imageType in [ImageType.large, .medium, .small] {
            let originalData = try #require(TestImage.data(size: imageType))
            let pngCompressedData = try #require(originalData.pngData())

            // Check file type
            #expect(originalData.isImage)
            #expect(pngCompressedData.imageType?.isPNGImage == true)


            #expect(originalData.count > 0)

            let compressionRatio = Double(pngCompressedData.count) / Double(originalData.count)
           
            let compressionPercent = Int((compressionRatio * 100).rounded()) - 100
            Logger.test.info(
                "\(imageType.rawValue): original size: \(originalData.count.outputKBytes), pngConverted: \(pngCompressedData.count.outputKBytes), compressionRatio: \(compressionPercent)%"
            )
            
            let originalSource = try #require(
                CGImageSourceCreateWithData(originalData as CFData, nil)
            )

            let originalImage = try #require(
                CGImageSourceCreateImageAtIndex(originalSource, 0, nil)
            )

            let pngSource = try #require(
                CGImageSourceCreateWithData(pngCompressedData as CFData, nil)
            )

            let pngImage = try #require(
                CGImageSourceCreateImageAtIndex(pngSource, 0, nil)
            )

            #expect(pngImage.width == originalImage.width)
            #expect(pngImage.height == originalImage.height)
        }
    }
}
