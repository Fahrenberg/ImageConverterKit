//
//  ImageCompressor.swift - Image compression
//  ImageCompressionKit
//
//  Created by Jean-Nicolas on 17.06.2026.
//

import Foundation
import CoreGraphics

public enum ImageConverter {
    public static let defaultHEICQuality: Double = 0.75
    public static let defaultJPEGQuality: Double = 0.65
    public static let defaultAlignment: ImageAlignment = .center
    public static let defaultBackground: ImageBackground = .white
    public enum ImageAlignment {
        case left, center, right
    }
    public enum ImageBackground {
        case transparent
        case white
        case black
        case color(CGColor)

        internal var cgColor: CGColor? {
            switch self {
            case .transparent:
                nil

            case .white:
                CGColor(
                    gray: 1,
                    alpha: 1
                )

            case .black:
                CGColor(
                    gray: 0,
                    alpha: 1
                )

            case .color(let color):
                color
            }
        }
    }
}




