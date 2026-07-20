//
//  -------------------------------------------------------------------
//  ---------------     Image Resize Tests      		 --------------
//  ---------------		                    			 --------------
//  -------				                                    	-------
//  -------------------------------------------------------------------

import Testing
import OSLog
import Extensions

@testable import ImageConverterKit


struct PlatformImageResizerTests {
    @Test func resizesSystemSymbolWithTransparentBackground() throws {
        let symbolImage = try #require(
            PlatformImage(systemName: "photo")
        )

        let sourceCGImage = try #require(
            symbolImage.platformCGImage
        )

        let targetSize = CGSize(
            width: 100,
            height: 80
        )

        let resizedCGImage = try #require(
            ImageConverter.resizedCGImage(
                from: sourceCGImage,
                toPixelSize: targetSize,
                background: .transparent
            )
        )

        #expect(resizedCGImage.width == 100)
        #expect(resizedCGImage.height == 80)

        #expect(
            resizedCGImage.colorSpace?.model == .rgb
        )
    }
    
    
    @Test(.disabled()) func resizePlatformImageChangingAspectRation() {
        
    }
    
    
}
