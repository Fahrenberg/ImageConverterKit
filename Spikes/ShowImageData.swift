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
    
    for filename in filenames {
        guard let imageData = try? readTestData(filename: filename) else {
            print("nil")
            return
        }
        
       
        
        
        _ = imageData.count
        _  = ImageCompressor.heicData(from: imageData, compressionQuality:  1.0)?.count
        
    }
    
}

