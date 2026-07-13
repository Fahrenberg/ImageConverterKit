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


import Extensions


#Playground {
    
    let filename = filenames[3]
    let imageData = try readTestData(filename: filename)
    _ = imageData.count.outputKBytes
    _ = PlatformImage(data: imageData)
    
    guard let compressedImageData = ImageConverter.heicData(from: imageData,quality: 0)
    else { return }
    _ = compressedImageData.count.outputKBytes
    _ = PlatformImage(data: compressedImageData)
    
}

