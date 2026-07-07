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


import UIKit


#Playground {
    
    let filename = filenames[3]
    let imageData = try readTestData(filename: filename)
    _ = imageData.count.outputKBytes
    _ = UIImage(data: imageData)
    
    guard let compressedImageData = ImageCompressor.heicData(from: imageData,compressionQuality: 0)
    else { return }
    _ = compressedImageData.count.outputKBytes
    _ = UIImage(data: compressedImageData)
    
}

