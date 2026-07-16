//
//  -------------------------------------------------------------------
//  ---------------     PlatformImageCompressionTests	 --------------
//  ---------------				                    	 --------------
//  -------					                                    -------
//  -------------------------------------------------------------------

import Testing
import OSLog

@testable import ImageCompressionKit

struct PlatformImageConverterTests {
    
    
    @Test func testHEICConverterWithLargeImage() throws {
        let image = try #require(TestImage.image(size: .large))
        let heicImageData = try #require(image.heicData())
        #expect(heicImageData.count > 0)
        #expect(heicImageData.imageType?.isHEICImage == true)
    }
    
    @Test func testJPGConverterWithLargeImage() throws {
        let image = try #require(TestImage.image(size: .large))
        let jpegImageData = try #require(image.jpgData())
        #expect(jpegImageData.count > 0)
        #expect(jpegImageData.imageType?.isJPGImage == true)
    }
    
    @Test func testPNGConverternWithLargeImage() throws {
        let image = try #require(TestImage.image(size: .large))
        let pngImageData = try #require(image.pngData())
        #expect(pngImageData.count > 0)
        #expect(pngImageData.imageType?.isPNGImage == true)
    }
}
