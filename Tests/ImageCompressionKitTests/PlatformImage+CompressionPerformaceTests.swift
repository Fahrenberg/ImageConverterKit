//
//  ------------------------------------------------
//  -----------   PerformanceTestHEICCompressor -----------------
//  ------------------------------------------------
//
    
import XCTest
@testable import ImageCompressionKit
import OSLog
import CollectionConcurrencyKit

final class ImageCompressionPerformanceTests: XCTestCase {
   
    var measureOnlyOnce: XCTMeasureOptions {
        let option = XCTMeasureOptions()
        option.iterationCount = 1
        return option
    }
    
    
    func testPerformanceJPGCompressorLargeData() throws {
        let jpgQuality: CGFloat = 0.1
        let image = try XCTUnwrap(TestImage.image(size: .large))
        
        self.measure(options: measureOnlyOnce) { // 0.025
            _ = image.jpgDataCompression(compressionQuality: jpgQuality)
        }
    }
    
    
    func testPerformanceHEICCompressorLargeData() throws {
        let heicQuality: CGFloat = 0.1
        let image = try XCTUnwrap(TestImage.image(size: .large))
        
        self.measure(options: measureOnlyOnce) { // 0.240
            _ = image.heicDataCompression(compressionQuality: heicQuality)
        }
    }
    
    func testPerformance4HEICCompressionsConcurrent() async throws {
        let heicQuality: CGFloat = 0.5
        let image = try XCTUnwrap(TestImage.image(size: .large))
        
        let images = Array(repeating: image, count: 4)
        
        self.measure(options: measureOnlyOnce) { // 1.552 sec
            let expectation = XCTestExpectation(description: "Concurrent HEIC compression completed")

            Task {
                await images.concurrentForEach { image in
                    _ =  image.heicDataCompression(compressionQuality: heicQuality)
                }
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 2.0)  // Adjust the timeout as necessary
        }
    }

    func testPerformance4HEICCompressionsSync() async throws {
        let heicQuality: CGFloat = 0.5
        let image = try XCTUnwrap(TestImage.image(size: .large))
        
        let images = Array(repeating: image, count: 4)
        
        self.measure(options: measureOnlyOnce){ // 1.17 sec
            images.forEach { image in
                    _ =  image.heicDataCompression(compressionQuality: heicQuality)
            }
        }
    }

    func testPerformance4JPGCompressionsConcurrent() async throws {
        let heicQuality: CGFloat = 0.5
        let image = try XCTUnwrap(TestImage.image(size: .large))
        
        let images = Array(repeating: image, count: 4)
        
        self.measure(options: measureOnlyOnce) { // 0.104 sec
            let expectation = XCTestExpectation(description: "Concurrent JPG compression completed")

            Task {
                await images.concurrentForEach { image in
                    _ = image.jpgDataCompression(compressionQuality: heicQuality)
                }
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 1.0)  // Adjust the timeout as necessary
        }
    }
    
    func testPerformance4JPGCompressionsSync() async throws {
        let heicQuality: CGFloat = 0.5
        let image = try XCTUnwrap(TestImage.image(size: .large))
        
        let images = Array(repeating: image, count: 4)
        
        self.measure { // 0.177 sec
             images.forEach { image in
                    _ = image.jpgDataCompression(compressionQuality: heicQuality)
            }
        }
    }
    
    
     
}
