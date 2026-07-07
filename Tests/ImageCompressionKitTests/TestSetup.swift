//
//  Logger.swift
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 27.10.2024.
//

import Foundation
import OSLog
import Extensions

@testable import ImageCompressionKit

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif


import Testing

extension Logger {
    static let subsystem = "\(Bundle.main.bundleIdentifier!)"
    static let test = Logger(subsystem: subsystem, category: "ImageCompressionTests")
}

enum ImageType: String, CaseIterable {
    case large, medium, small, small_center, small_left, small_right
    
    var imageAlignment: PlatformImage.ImageAlignment {
        switch self {
        case .small_center:
            return .center
        case .small_left:
            return .left
        case .small_right:
            return .right
        default:
            return .center
        }
    }
}

struct TestImage {
    static func image(size type: ImageType) -> PlatformImage? {
        let bundle = Bundle.module
        guard let imageURL = bundle.url(forResource: type.rawValue, withExtension: "bmp") else {
            return nil
        }
        #if canImport(UIKit)
        return UIImage(contentsOfFile: imageURL.path)
        #elseif canImport(AppKit)
        return NSImage(contentsOf: imageURL)
        #endif
    }
    
    static func data(size type: ImageType) -> Data? {
        let bundle = Bundle.module
        guard let imageURL = bundle.url(forResource: type.rawValue, withExtension: "bmp") else {
            return nil
        }
        let data = try? Data(contentsOf: imageURL)
        return data
    }
}

struct TestImageAccess {
    
    @Test func testAccessToPlatformImage() {
        let largeImage = TestImage.image(size: .large)
        #expect(largeImage != nil)
        Logger.test.info("largeImage  size: \(largeImage?.sizeDescription ?? "nil", privacy: .public)")
        
        let mediumImage = TestImage.image(size: .medium)
        #expect(mediumImage != nil)
        Logger.test.info("mediumImage size: \(mediumImage?.sizeDescription ?? "nil", privacy: .public)")
        
        let smallImage = TestImage.image(size: .small)
        #expect(smallImage != nil)
        Logger.test.info("smallImage  size: \(smallImage?.sizeDescription ?? "nil", privacy: .public)")
    }
    
    @Test func testLargeImageData() throws {
        let largeData = try #require(TestImage.data(size: .large))
        let imageType = largeData.imageType?.isHEICImage ?? false ? "YES" : "NO/nil"
        Logger.test.info("LargeData HEIC? \(imageType): \(largeData.count.outputKBytes)")
        #expect(largeData.count == 20868670)
    }
    
    @Test func testMediumImageData() throws {
        let mediumData = try #require(TestImage.data(size: .medium))
        let imageType = mediumData.imageType?.isHEICImage ?? false ? "YES" : "NO/nil"
        Logger.test.info("MediumData HEIC? \(imageType): \(mediumData.count.outputKBytes)")
        #expect(mediumData.count == 1747579)
    }
    
    @Test func testSmallImageData() throws {
        let smallData = try #require(TestImage.data(size: .small))
        let imageType = smallData.imageType?.isHEICImage ?? false ? "YES" : "NO/nil"
        Logger.test.info("SmallData HEIC? \(imageType): \(smallData.count.outputKBytes)")
        #expect(smallData.count == 384471)
    }
    
}

