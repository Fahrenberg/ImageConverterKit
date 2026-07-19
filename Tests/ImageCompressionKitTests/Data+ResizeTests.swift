//
//  Data+ResizeTests.swift
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 19.07.2026.
//
import Testing
import OSLog
import Extensions
import ImageIO
import UniformTypeIdentifiers

@testable import ImageCompressionKit

struct ImageDataResizeTests {
    
    @Test func halfImageSizeJPG() throws {
//        let filename = ImageType.JPG_Scan.rawValue + "-halfImageSize"  + ".bmp"
        let originalData = try #require(TestImage.data(size: .JPG_Scan))
        let originalCGImage = try #require(originalData.platformCGImage)
        let orignalSize = CGSize(width: originalCGImage.width, height: originalCGImage.height)
        
        let targetSize: CGSize = orignalSize * 0.5
        
        let resizedImageData = try #require(originalData.resizeImage(to: targetSize))
        #expect(resizedImageData.imageType == originalData.imageType)
        let resultCGImage = try #require(resizedImageData.platformCGImage)
        let resultSize = CGSize(width: resultCGImage.width, height: resultCGImage.height)
        #expect(resultSize == targetSize)
        
//        try resizedImageData.writeToDisk(filename: filename)
    }
    
    @Test func doubleImageSizeJPG() throws {
//        let filename = ImageType.JPG_Scan.rawValue + "-doubleImageSize"  + ".bmp"
        let originalData = try #require(TestImage.data(size: .JPG_Scan))
        let originalCGImage = try #require(originalData.platformCGImage)
        let orignalSize = CGSize(width: originalCGImage.width, height: originalCGImage.height)
        
        let targetSize: CGSize = orignalSize * 2
        
        let resizedImageData = try #require(originalData.resizeImage(to: targetSize))
        #expect(resizedImageData.imageType == originalData.imageType)
        let resultCGImage = try #require(resizedImageData.platformCGImage)
        let resultSize = CGSize(width: resultCGImage.width, height: resultCGImage.height)
        #expect(resultSize == targetSize)
        
//        try resizedImageData.writeToDisk(filename: filename)
        
        
    }
    
    
}

