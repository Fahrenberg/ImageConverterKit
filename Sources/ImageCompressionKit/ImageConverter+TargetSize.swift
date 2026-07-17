//
//  ImageConverter+TargetSize.swift
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 17.07.2026.
//

import Foundation
import UniformTypeIdentifiers
import ImageIO
import Extensions
import OSLog

extension ImageConverter {
    /// Converts image data and searches for a compression quality whose resulting
    /// size is as close as possible to the requested size.
    ///
    /// The search assumes that increasing the quality produces larger output data.
    ///
    /// - Parameters:
    ///   - imageData: The source image data.
    ///   - type: The destination image type.
    ///   - askedMaxSize: The target data size in bytes.
    ///
    /// - Returns: Converted data within the accepted tolerance when possible.
    ///   Otherwise, returns the closest result found during the search.
    internal static func convertData(
        from imageData: Data,
        to type: UTType,
        with askedMaxSize: Int
    ) -> Data? {
        guard askedMaxSize > 0 else {
            return nil
        }
        
        let tolerance = 0.2
        let minimumSize = Int(
            Double(askedMaxSize) * (1.0 - tolerance)
        )
        let maximumSize = askedMaxSize
        
        let defaultQuality = ImageConverter.defaultHEICQuality
        let maximumQuality = 0.99
        let maxAttempts = 10
        
        guard let defaultData = ImageConverter.convertData(
            from: imageData,
            type: type,
            quality: defaultQuality
        ) else {
            Logger.source.debug(
                "Conversion failed for \(type.description)."
            )
            return nil
        }
        
        if (minimumSize...maximumSize).contains(defaultData.count) {
            logSuccessfulConversion(
                askedMaxSize: askedMaxSize,
                quality: defaultQuality,
                attempts: 1
            )
            
            return defaultData
        }
        
        var lowerQuality: Double
        var upperQuality: Double
        
        if defaultData.count < minimumSize {
            // The result is too small, so only search higher qualities.
            lowerQuality = defaultQuality
            upperQuality = maximumQuality
        } else {
            // The result is too large, so only search lower qualities.
            lowerQuality = 0
            upperQuality = defaultQuality
        }
        
        var bestResult = CompressionResult(
            data: defaultData,
            quality: defaultQuality,
            distanceFromTarget: abs(defaultData.count - askedMaxSize)
        )
        
        var attempts = 1
        
        while attempts < maxAttempts {
            attempts += 1
            
            let quality = (lowerQuality + upperQuality) / 2
            
            guard let convertedData = ImageConverter.convertData(
                from: imageData,
                type: type,
                quality: quality
            ) else {
                return nil
            }
            
            let dataSize = convertedData.count
            let distanceFromTarget = abs(dataSize - askedMaxSize)
            
            if distanceFromTarget < bestResult.distanceFromTarget {
                bestResult = CompressionResult(
                    data: convertedData,
                    quality: quality,
                    distanceFromTarget: distanceFromTarget
                )
            }
            
            if (minimumSize...maximumSize).contains(dataSize) {
                logSuccessfulConversion(
                    askedMaxSize: askedMaxSize,
                    quality: quality,
                    attempts: attempts
                )
                
                return convertedData
            }
            
            if dataSize < minimumSize {
                // Too small: increase quality.
                lowerQuality = quality
            } else {
                // Too large: decrease quality.
                upperQuality = quality
            }
        }
        
        Logger.source.warning(
            """
            Exact compression range not reached.
            Requested max. size: \(askedMaxSize.outputKBytes)
            Resulting size: \(bestResult.data.count.outputKBytes)
            Compression quality: \(bestResult.quality)
            Attempts: \(attempts)
            """
        )
        
        return bestResult.data
    }
    
    private struct CompressionResult {
        let data: Data
        let quality: Double
        let distanceFromTarget: Int
    }
    
    private static func logSuccessfulConversion(
        askedMaxSize: Int,
        quality: Double,
        attempts: Int
    ) {
        Logger.source.debug(
            """
            Compression completed.
            Requested size: \(askedMaxSize.outputKBytes)
            Compression quality: \(quality)
            Attempts: \(attempts)
            """
        )
    }
}



