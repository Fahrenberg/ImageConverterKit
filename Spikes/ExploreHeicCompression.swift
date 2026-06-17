//
//  ScanSpikes.swift
//  Database
//
//  Created by Jean-Nicolas on 17.05.2026.
//

import Playgrounds
import Foundation
import UniformTypeIdentifiers
import ImageIO
import Extensions
import ImageCompressionKit

extension PlatformImage {
    /// Convert scan image to data for saving
    var scanData: Data? {
//        if #available(iOS 17.0, *) {
//            return self.heicData()
//        } else {
//            fatalError("Using Old Data Compression")
            return self.heicDataCompression(compressionQuality: 0.5)
//        }
    }
}


func readTestScan(filename: String) throws -> Data {
        guard let imageURL = try? readScanURL(filename: filename) else {
            throw( "not a valid bundle url for \(filename)")
        }
        guard let data = try? Data(contentsOf: imageURL) else {
            throw("No \(filename) file.")
        }
        return data
}


func readScanURL(filename: String) throws -> URL {
    let bundle = Bundle.module
    guard let imageURL = bundle.url(forResource: filename, withExtension: nil) else {
        throw( "not a valid bundle url for \(filename)")
    }
    return imageURL
}

/// Checks whether the image file at the given URL is encoded using the HEIC/HEIF format.
///
/// The method creates a `CGImageSource` from the file URL, extracts its Uniform Type Identifier,
/// and verifies whether the type matches or conforms to `UTType.heic` or `UTType.heif`.
///
/// - Parameter url: The file URL of the image to inspect.
/// - Returns: `true` if the file is a HEIC or HEIF image; otherwise `false`.
func isHEICFile(at url: URL) -> Bool {
    guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
          let type = CGImageSourceGetType(imageSource) else {
        return false
    }

    let utType = UTType(type as String)

    return utType == .heic ||
           utType == .heif ||
           utType?.conforms(to: .heic) == true ||
           utType?.conforms(to: .heif) == true
}



#Playground("Compare heic() compression with ImageIO " ) {
    /// Compare Apple .heic() API compression with ImageIO different compression quality
    ///
   let filenames = [
    "HEIC-Scan.heic",
    "JPG-Scan.jpg",
    "PNG-Scan-1.png",
    "JPG-Large.jpg",
    "TIFF.tif"
   ]
    let filename = filenames[4]
    let data: Data = try readTestData(filename: filename)
    let image = PlatformImage(data: data)!
    
    let heicData50: Data = image.heicDataCompression(compressionQuality: 0.5) ?? Data()
    let heicData75: Data = image.heicDataCompression(compressionQuality: 0.75) ?? Data()
    let heicData90: Data = image.heicDataCompression(compressionQuality: 0.9) ?? Data()
    if #available(iOS 17.0, *) {
        let heicAPI: Data = image.heicData() ?? Data()
    }
}

#Playground("Compare HEIC compression table") {
    enum TextAlignment { case left, right }
    func padded(_ text: String, to length: Int, alignment: TextAlignment = .right) -> String {
        guard text.count < length else { return text }

        let padding = String(repeating: " ", count: length - text.count)

        switch alignment {
        case .left:
            return text + padding
        default:
            return padding + text
        }
    }

    let filenames = [
        "HEIC-Scan.heic",
        "JPG-Scan.jpg",
        "PNG-Scan-1.png",
        "JPG-Large.jpg",
        "TIFF.tif"
    ]

    let filenameColumnWidth = 18
    let sizeColumnWidth = 12

    let headers = [
        padded("Filename", to: filenameColumnWidth, alignment: TextAlignment.left),
        padded("Original", to: sizeColumnWidth),
        padded("heic50", to: sizeColumnWidth),
        padded("heic75", to: sizeColumnWidth),
        padded("heic90", to: sizeColumnWidth),
        padded("heic(API)", to: sizeColumnWidth)
    ]

    let header = headers.joined(separator: "  ")
    print(header)
    print(String(repeating: "-", count: header.count))

    for filename in filenames {
        let originalData = try readTestData(filename: filename)
        guard let image = PlatformImage(data: originalData) else {
            print("\(filename): Could not create image")
            continue
        }

        let heicData50 = image.heicDataCompression(compressionQuality: 0.5)
        let heicData75 = image.heicDataCompression(compressionQuality: 0.75)
        let heicData90 = image.heicDataCompression(compressionQuality: 0.9)

        let heicAPI: Data?
        if #available(iOS 17.0, *) {
            heicAPI = image.heicData()
        } else {
            heicAPI = nil
        }

        let columns = [
            padded(filename, to: filenameColumnWidth, alignment: TextAlignment.left),
            padded(originalData.count.outputKBytes, to: sizeColumnWidth),
            padded(heicData50?.count.outputKBytes ?? "nil", to: sizeColumnWidth),
            padded(heicData75?.count.outputKBytes ?? "nil", to: sizeColumnWidth),
            padded(heicData90?.count.outputKBytes ?? "nil", to: sizeColumnWidth),
            padded(heicAPI?.count.outputKBytes ?? "n/a", to: sizeColumnWidth)
        ]

        print(columns.joined(separator: "  "))
    }
}

#Playground("Multiple HEIC compression") {
    let filename = "HEIC-Scan.heic"
    let data: Data = try readTestData(filename: filename)
    let heicData1: Data = PlatformImage(data: data)?.makeHEICData ?? Data()
    let heicData2: Data = PlatformImage(data: heicData1)?.makeHEICData ?? Data()
    let heicData3: Data = PlatformImage(data: heicData2)?.makeHEICData ?? Data()
    
    let image = PlatformImage(data: heicData3)
}


