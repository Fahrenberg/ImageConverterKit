//
//  HEICWithData.swift
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 16.06.2026.
//

import Playgrounds
import Foundation
import UniformTypeIdentifiers
import ImageIO
import Extensions
import ImageCompressionKit

func imageType(for data: Data) -> UTType? {
    guard let source = CGImageSourceCreateWithData(data as CFData, nil),
          let type = CGImageSourceGetType(source),
          let utType = UTType(type as String)
    else {
        return nil
    }

    return utType.conforms(to: .image) ? utType : nil
}

func isHEICData(_ data: Data) -> Bool {
    guard let utImageType = imageType(for: data)
    else { return false}

    return
        utImageType.conforms(to: .heic) == true ||
        utImageType.conforms(to: .heif) == true
}



#Playground("Image Types") {
    let filenames = [
     "HEIC-Scan.heic",
     "JPG-Scan.jpg",
     "PNG-Scan-1.png",
     "JPG-Large.jpg",
     "TIFF.tif",
     "Sample-Word-DOC.docx",
     "SamplePDF.pdf"
    ]
   
    for filename in filenames {
        let data: Data = try readTestData(filename: filename)
        let imageType = imageType(for: data)
        let heicImage = isHEICData(data)
    }
    
}
