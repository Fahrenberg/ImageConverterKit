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
   fileprivate var scanData: Data? {
//        if #available(iOS 17.0, *) {
//            return self.heicData()
//        } else {
//            fatalError("Using Old Data Compression")
            return self.heicDataCompression(compressionQuality: 0.5)
//        }
    }
}

#Playground {
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
    
    
    
    
    do {
        let filenames = [ "HEIC-Scan.heic",
                           "JPG-Scan.jpg",
                           "PNG-Scan-1.png",
                            "JPG-Large.jpg",
                          "TIFF.tif"
                        ]
//        let filenames = [
//            "JPG-Large.jpg",
//                        ]
        
        for filename in filenames {
            let url = try readScanURL(filename: filename)
            let data = try readTestScan(filename: filename)
            if isHEICFile(at: url) {
                print("\(filename)  is heic, data = \(data.count.outputKBytes)")
            } else {
                let heicData = PlatformImage(data: data)?.scanData?.count ?? -1
                let dataCount = data.count
                let percentage = Double(heicData) / Double(dataCount) * 100 - 100
                let formattedPercentage =  String(format: "%.0f%%", percentage)
                print("\(filename)  NOT heic, data = \(dataCount.outputKBytes), converted data = \(heicData.outputKBytes), \(formattedPercentage)")
            }
        }
        
        
    } catch {
        print(error.localizedDescription)
    }
}
