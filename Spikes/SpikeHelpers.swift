//
//  SpikeHelpers.swift
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 16.06.2026.
//

import Foundation
import Extensions


func readTestData(filename: String) throws -> Data {
        guard let imageURL = try? readTestDataURL(filename: filename) else {
            throw( "not a valid bundle url for \(filename)")
        }
        guard let data = try? Data(contentsOf: imageURL) else {
            throw("No \(filename) file.")
        }
        return data
}


func readTestDataURL(filename: String) throws -> URL {
    let bundle = Bundle.module
    guard let imageURL = bundle.url(forResource: filename, withExtension: nil) else {
        throw( "not a valid bundle url for \(filename)")
    }
    return imageURL
}
extension PlatformImage {
    /// Convert image to HEIC data
    var makeHEICData: Data? {
        // if heic do nothing!
        return self.heicDataCompression(compressionQuality: 0.75)
    }
}
