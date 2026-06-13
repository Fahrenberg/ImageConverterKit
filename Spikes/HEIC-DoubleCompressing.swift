//
//  HEIC-Compressing.swift
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 13.06.2026.
//

import Playgrounds
import Foundation
import UniformTypeIdentifiers
import ImageIO
import Extensions

import ImageCompressionKit

 
#if os(macOS)
#Playground("Reading HEIC, compress again with heic and saving to Desktop"){
    let filename = "HEIC-Scan.heic"
    let url = try readScanURL(filename: filename)
    let data = try readTestScan(filename: filename)
    guard let heicData = PlatformImage(data: data)?.scanData else {
        throw "Failed to create HEIC data"
    }
    
    let dataCount = data.count
    let percentage = Double(heicData.count) / Double(dataCount) * 100 - 100
    let formattedPercentage =  String(format: "%.0f%%", percentage)
    print("\(filename):  heic original data = \(dataCount.outputKBytes), heich compressed  data = \(heicData.count.outputKBytes), \(formattedPercentage)")
    
    
    let desktopDirectory = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
    let destinationURL = desktopDirectory.appendingPathComponent(filename)
    print(destinationURL.absoluteString)
    try heicData.write(to: destinationURL)
}
#endif // os(macOS)
