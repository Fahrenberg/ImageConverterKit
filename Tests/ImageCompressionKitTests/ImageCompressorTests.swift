//
//  ImageCompressorTests.swift
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 18.06.2026.
//

import Testing
import OSLog
import Extensions
import ImageIO
import UniformTypeIdentifiers

@testable import ImageCompressionKit

struct ImageCompressorTests {
    
    @Test func heicImageCompression() throws {
        for imageType in [ImageType.large, .medium, .small] {
            let originalData = try #require(TestImage.data(size: imageType))
            let heicCompressedData = try #require(ImageCompressor.heicData(from: originalData))

            // Check file type
            #expect(originalData.isImage)
            #expect(heicCompressedData.isHEICImage)


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
    
    @Test func jpegImageCompression() throws {
        for imageType in [ImageType.large, .medium, .small] {
            let originalData = try #require(TestImage.data(size: imageType))
            let jpegCompressedData = try #require(ImageCompressor.jpegData(from: originalData))

            // Check file type
            #expect(originalData.isImage)
            #expect(!jpegCompressedData.isHEICImage)


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
    
}
