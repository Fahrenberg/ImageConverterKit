//
//  -------------------------------------------------------------------
//  ---------------     PlatformImageCompressionTests	 --------------
//  ---------------				                    	 --------------
//  -------					                                    -------
//  -------------------------------------------------------------------

import Testing
import OSLog

@testable import ImageCompressionKit

struct PlatformImageCompressionTests {


    @Test func testHEICCompressionWithLargeImage() throws {
        let image = try #require(TestImage.image(size: .large))
        let heicImageData = try #require(image.heicData())
        #expect(heicImageData.count > 0)
        #expect(heicImageData.imageType?.isHEICImage == true)

    }

    @Test func testJPGCompressionWithLargeImage() throws {
        let image = try #require(TestImage.image(size: .large))
        let jpegImageData = try #require(image.jpgData())
        #expect(jpegImageData.count > 0)
        #expect(jpegImageData.imageType?.isJPGImage == true)
    }
    
    @Test func testPNGConversionWithLargeImage() throws {
        let image = try #require(TestImage.image(size: .large))
        let pngImageData = try #require(image.pngData())
        #expect(pngImageData.count > 0)
        #expect(pngImageData.imageType?.isPNGImage == true)
    }
    
/*
    //MARK: Using askedMaxSize (bytes)
    func testHEICCompressToSize() throws {
        let maxExpectedSize: UInt64 = 300_000  // max. compression ~0.1
        let image = try XCTUnwrap(TestImage.image(size: .large))
        let originalSize = try XCTUnwrap(image.pngData()?.count)
        
        let compressedData = image.heicDataCompression(askedMaxSize: maxExpectedSize)
        let resultSize =  UInt64(try XCTUnwrap(compressedData?.count))
        
        let maxSize = UInt64( Double(maxExpectedSize) * 1.1)
        XCTAssertLessThan(resultSize, maxSize ) // +10% deviation allowed
        
        let minSize = UInt64( Double(maxExpectedSize) * 0.9)
        XCTAssertGreaterThan(resultSize, minSize) // -10% deviation allowed
        
        Logger.test.info(
            """
            testHEICCompressToSize:
            Original-Size: \(originalSize)
            Compressed-Size: \(resultSize)
            Factor: \(Double(originalSize) / (Double(resultSize)))x smaller
            """
            )
    }
    
    func testJPGCompressToSize() throws {
        let maxExpectedSize: UInt64 = 500_000  // max. compression ~0.1
        let image = try XCTUnwrap(TestImage.image(size: .large))
        let originalSize = try XCTUnwrap(image.pngData()?.count)
        
        let compressedData = image.jpgDataCompression(askedMaxSize: maxExpectedSize)
        let resultSize =  UInt64(try XCTUnwrap(compressedData?.count))
        
        let maxSize = UInt64( Double(maxExpectedSize) * 1.1)
        XCTAssertLessThan(resultSize, maxSize ) // +10% deviation allowed
        
        let minSize = UInt64( Double(maxExpectedSize) * 0.9)
        XCTAssertGreaterThan(resultSize, minSize) // -10% deviation allowed
        
        Logger.test.info(
            """
            testJPGCompressToSize:
            Original-Size: \(originalSize)
            Compressed-Size: \(resultSize)
            Factor: \(Double(originalSize) / (Double(resultSize)))x smaller
            """
            )
    }

    
    
    //MARK: nil Image
    func testNilImageWithHEICCompression() throws {
    #if canImport(UIKit)
        class MockImage: UIImage, @unchecked Sendable {
            override var cgImage: CGImage? {
                return nil // Always return nil for testing purposes
            }
        }
    #elseif canImport(AppKit)
        final class MockImage: NSImage, @unchecked Sendable {
            override func cgImage(
                forProposedRect proposedRect: UnsafeMutablePointer<NSRect>?,
                context: NSGraphicsContext?,
                hints: [NSImageRep.HintKey : Any]?
            ) -> CGImage? {
                return nil // Always return nil for testing purposes
            }
        }
    #else
        fatalError("Unsupported platform (iOS or macOS only)")
    #endif
        let image = MockImage()
        let compressedData = image.heicDataCompression()
        XCTAssertNil(compressedData)
    }

    
    func testHEICCompressionQualityOutOfBounds() throws {
        let image = try XCTUnwrap(TestImage.image(size: .large))
           
           // Test compressionQuality < 0
           let dataNegativeQuality = image.heicDataCompression(compressionQuality: -1.0)
           XCTAssertNotNil(dataNegativeQuality, "Data should not be nil for out-of-bounds quality < 0")
           
           // Test compressionQuality > 1
           let dataHighQuality = image.heicDataCompression(compressionQuality: 2.0)
           XCTAssertNotNil(dataHighQuality, "Data should not be nil for out-of-bounds quality > 1")
           
           // Test compressionQuality = 0
           let dataZeroQuality = image.heicDataCompression(compressionQuality: 0.0)
           XCTAssertNotNil(dataZeroQuality, "Data should not be nil for quality = 0")
           
           // Test compressionQuality = 1
           let dataMaxQuality = image.heicDataCompression(compressionQuality: 1.0)
           XCTAssertNotNil(dataMaxQuality, "Data should not be nil for quality = 1")
       }
       
    func testJPGCompressionQualityOutOfBounds() throws {
        let image = try XCTUnwrap(TestImage.image(size: .large))
           
           // Test compressionQuality < 0
           let dataNegativeQuality = image.jpgDataCompression(compressionQuality: -1.0)
           XCTAssertNotNil(dataNegativeQuality, "Data should not be nil for out-of-bounds quality < 0")
           
           // Test compressionQuality > 1
           let dataHighQuality = image.jpgDataCompression(compressionQuality: 2.0)
           XCTAssertNotNil(dataHighQuality, "Data should not be nil for out-of-bounds quality > 1")
           
           // Test compressionQuality = 0
           let dataZeroQuality = image.jpgDataCompression(compressionQuality: 0.0)
           XCTAssertNotNil(dataZeroQuality, "Data should not be nil for quality = 0")
           
           // Test compressionQuality = 1
           let dataMaxQuality = image.jpgDataCompression(compressionQuality: 1.0)
           XCTAssertNotNil(dataMaxQuality, "Data should not be nil for quality = 1")
       }
    
    func testHEICCompressionWithEqualOrMoreThan6Attempts() throws {
        let askedMaxSize: UInt64 = 10_000  // too small, returns higher size with max. compression
        
        let image = try XCTUnwrap(TestImage.image(size: .large))
        let originalSize = try XCTUnwrap(image.pngData()?.count)
        
        let compressedData = image.heicDataCompression(askedMaxSize: askedMaxSize)

        let maxExpectedSize: UInt64 = 85_000 // max compression size
        let resultSize =  UInt64(try XCTUnwrap(compressedData?.count))
        
        let maxSize = UInt64( Double(maxExpectedSize) * 1.1)
        XCTAssertLessThan(resultSize, maxSize ) // +10% deviation allowed
        
        XCTAssertGreaterThan(resultSize, 0) // not 0 data
        
        Logger.test.debug(
            """
            testHEICCompressionWithEqualOrMoreThan7Attempts:
            Original-Size: \(originalSize)
            Compressed-Size: \(resultSize)
            Factor: \(Double(originalSize) / (Double(resultSize)))x smaller
            """
            )
    }
    
    
    func testJPGCompressionWithEqualOrMoreThan6Attempts() throws {
        let askedMaxSize: UInt64 = 100_000  // too small, returns higher size with max. compression
        let image = try XCTUnwrap(TestImage.image(size: .large))
        let originalSize = try XCTUnwrap(image.pngData()?.count)
        
        let compressedData = image.jpgDataCompression(askedMaxSize: askedMaxSize)
        let resultSize =  UInt64(try XCTUnwrap(compressedData?.count))
      
        let maxExpectedSize: UInt64 = 500_000 // max compression size
        let maxSize = UInt64( Double(maxExpectedSize) * 1.1)
        XCTAssertLessThan(resultSize, maxSize ) // +10% deviation allowed
        
        
        XCTAssertGreaterThan(resultSize, 0) // not 0 data
        
        Logger.test.error(
            """
            testJPGCompressionWithEqualOrMoreThan6Attempts:
            Original-Size: \(originalSize)
            Compressed-Size: \(resultSize)
            Factor: \(Double(originalSize) / (Double(resultSize)))x smaller
            """
            )
    }
    */
    
}

