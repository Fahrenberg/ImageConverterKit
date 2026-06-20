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
    
    @Test func testLargeImageData() {
        let largeData = TestImage.data(size: .large)
        Logger.test.info("LargeData : \(largeData?.count.outputKBytes ?? "nil")")
        #expect(largeData != nil && largeData!.count == 20868670)
    }
    
    @Test func testMediumImageData() {
        let mediumData = TestImage.data(size: .medium)
        Logger.test.info("MediumData : \(mediumData?.count.outputKBytes ?? "nil")")
        #expect(mediumData != nil && mediumData!.count == 1747579)
    }
    
    @Test func testSmallImageData() {
        let smallData = TestImage.data(size: .small)
        Logger.test.info("SmallData : \(smallData?.count.outputKBytes ?? "nil")")
        #expect(smallData != nil && smallData!.count == 384471)
    }
    
}

