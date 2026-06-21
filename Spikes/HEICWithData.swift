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
        let _ = data.isImage
        let _ = data.isHEICImage
    }
    
}

#Playground("Image Dimension") {
    let filename = "JPG-Large.jpg"
    guard let originalData: Data = try? readTestData(filename: filename),
          let originalSource = try CGImageSourceCreateWithData(originalData as CFData, nil),
          let originalImage = try
        CGImageSourceCreateImageAtIndex(originalSource, 0, nil)
    else { return  }
    _ = originalImage.width
    _ = originalImage.height
    
    let heicData = ImageCompressor.heicData(from: originalData)
    guard let heicData: Data = try? readTestData(filename: filename),
          let heicSource = try CGImageSourceCreateWithData(heicData as CFData, nil),
          let heicImage = try
        CGImageSourceCreateImageAtIndex(heicSource, 0, nil)
    else { return  }
    _ = heicImage.width
    _ = heicImage.height
    
}
