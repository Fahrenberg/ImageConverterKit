//
//  -------------------------------------------------------------------
//  ---------------     Image Resize Tests      		 --------------
//  ---------------		                    			 --------------
//  -------				                                    	-------
//  -------------------------------------------------------------------

import XCTest
import OSLog
import Extensions

@testable import ImageCompressionKit

final class ImageResizeTests: XCTestCase {
    
    override func setUpWithError() throws {
        let tmpDir = try PlatformImage.tempDirectory()
        FileManager.deleteAllFiles(directoryURL: tmpDir)  // delete all tested images
    }
    
    func testResizeMediumImage() throws {
        let baseImage = try XCTUnwrap(TestImage.image(size: .medium))
        Logger.test.info("image size: \(baseImage.sizeDescription, privacy: .public)")
        let expectedHeight = 500
        let expectedWidth = 500
        
        // ** function resized to test **
        let resizedImageWrapped = baseImage.resized(to: CGSize(width: expectedWidth, height: expectedHeight))
        // **
        let resizedImage = try XCTUnwrap(resizedImageWrapped)
        
        let resultWidth = Int(resizedImage.size.width)
        let resultHeight = Int(resizedImage.size.height)
        Logger.test.info("resizedImage has size: \(resizedImage.sizeDescription, privacy: .public)")
        
        XCTAssertEqual(resultHeight, expectedHeight)
        XCTAssertEqual(resultWidth, expectedWidth)
        
        let framedImage = resizedImage.addFrame().fillFrame() // for better visibility fill and frame image
        Logger.test.info("framedImage has size: \(framedImage.sizeDescription, privacy: .public)")
        // write resizedImage to disk for preview
        try framedImage.writeToDisk(filename: "testResizeMediumImage.bmp")
    }
    
    func testAlignmentsForResizedImage() throws {
        let baseImage = try XCTUnwrap(TestImage.image(size: .small))
        Logger.test.info("image size: \(baseImage.sizeDescription, privacy: .public)")
        
        for imageType in [ImageType.small_left,ImageType.small_center, ImageType.small_right] {
            let imageAligned = try XCTUnwrap(TestImage.image(size: imageType))
            Logger.test.info("imageAligned \(imageType.rawValue, privacy: .public) has size: \(imageAligned.sizeDescription, privacy: .public)")
            let expectedHeight = Int(imageAligned.size.height)
            let expectedWidth = Int(imageAligned.size.width)
            
            let resizedImageWrapped = baseImage.resized(
                to: CGSize(width: expectedWidth, height: expectedHeight),
                alignment: imageType.imageAlignment
                )
            let resizedImage = try XCTUnwrap(resizedImageWrapped)
            let resultWidth = Int(resizedImage.size.width)
            let resultHeight = Int(resizedImage.size.height)
            Logger.test.info("resizedImage \(imageType.rawValue, privacy: .public) has size: \(resizedImage.sizeDescription, privacy: .public)")
            XCTAssertEqual(resultHeight, expectedHeight)
            XCTAssertEqual(resultWidth, expectedWidth)
            let savedResizedImage = resizedImage.addFrame().fillFrame() // for better visibility
            // write resizedImage to disk for preview
            try savedResizedImage.writeToDisk(filename: "testAlignmentsForResizedImage-\(imageType.rawValue).bmp")
        }
    }
}
