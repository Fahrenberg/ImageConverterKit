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
    
    
    @Test func convertsImageToHEICWithLargeImage() throws {
        let image = try #require(TestImage.image(size: .large))
        let heicImageData = try #require(image.heicData())
        #expect(heicImageData.count > 0)
        #expect(heicImageData.imageType?.isHEICImage == true)
    }
    
    @Test func convertsImageToHEICWithinAskedMaxSize() throws {
        let image = try #require(TestImage.image(size: .large))
        let askedMaxSize: Int = ImageType.large.askedMaxSize(for: .heic)
        
        let heicImageData = try #require(image.heicData(askedMaxSize: askedMaxSize))
        #expect(heicImageData.count > 0 && heicImageData.count <= askedMaxSize)
        #expect(heicImageData.imageType?.isHEICImage == true)
        
    }
    
    @Test func convertsImaageToJPGWithLargeImage() throws {
        let image = try #require(TestImage.image(size: .large))
        let jpegImageData = try #require(image.jpgData())
        #expect(jpegImageData.count > 0)
        #expect(jpegImageData.imageType?.isJPGImage == true)
    }
    
    @Test func convertsImageToJPEGWithinAskedMaxSize() throws {
        let image = try #require(TestImage.image(size: .large))
        let askedMaxSize: Int = ImageType.large.askedMaxSize(for: .jpeg)
        
        let jpegImageData = try #require(image.jpgData(askedMaxSize: askedMaxSize))
        #expect(jpegImageData.count > 0 && jpegImageData.count <= askedMaxSize)
        #expect(jpegImageData.imageType?.isJPGImage == true)
        
    }
    
    @Test func convertsImageToPNGWithLargeImage() throws {
        let image = try #require(TestImage.image(size: .large))
        let pngImageData = try #require(image.pngData())
        #expect(pngImageData.count > 0)
        #expect(pngImageData.imageType?.isPNGImage == true)
    }
}
