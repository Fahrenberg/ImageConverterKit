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
    
    @Test func imageDataCompression() throws {
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
    
    
}
