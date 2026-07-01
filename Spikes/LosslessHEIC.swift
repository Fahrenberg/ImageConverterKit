//
//  LosslessHEIC.swift
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 29.06.2026.
//


import Foundation
import ImageIO
import AVFoundation
import CoreGraphics
import UniformTypeIdentifiers
import Playgrounds
import ImageCompressionKit

#Playground {
    
    let filenames = [
     "HEIC-Scan.heic",
     "JPG-Scan.jpg",
     "PNG-Scan-1.png",
     "JPG-Large.jpg",
     "TIFF.tif",
     "Sample-Word-DOC.docx",
     "SamplePDF.pdf"
    ]
    
    
    guard let imageData = try? readTestData(filename:      filenames[3]) else {
        print("nil")
        return
    }
    _ = imageData.count
    
}

