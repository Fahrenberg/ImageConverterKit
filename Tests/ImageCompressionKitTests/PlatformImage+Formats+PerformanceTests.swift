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
        option.iterationCount = 2
        return option
    }
    
    
    func testPerformanceJPGCompressorLargeData() throws {
        let jpgQuality: CGFloat = 0.1
        let image = try XCTUnwrap(TestImage.image(size: .large))
        
        self.measure(options: measureOnlyOnce) { // 0.439 (2x), macmini m4 pro simulator
            _ = try? XCTUnwrap(image.jpgData(quality: jpgQuality))
        }
    }
    
    func testPerformanceHEICCompressorLargeData() throws {
        let heicQuality: CGFloat = 0.1
        let image = try XCTUnwrap(TestImage.image(size: .large))
        
        self.measure(options: measureOnlyOnce) { // 0.556 (2x)
            _ = try? XCTUnwrap(image.heicData(quality: heicQuality))
        }
    }
    
    func testPerformance4HEICCompressionsConcurrent() async throws {
        let heicQuality: CGFloat = 0.5
        let image = try XCTUnwrap(TestImage.image(size: .large))
        
        let images = Array(repeating: image, count: 4)
        
        self.measure(options: measureOnlyOnce) { // 1.133 sec
            let expectation = XCTestExpectation(description: "Concurrent HEIC compression completed")

            Task {
                await images.concurrentForEach(withPriority: .background) { image in
                    _ =  try? XCTUnwrap(image.heicData(quality: heicQuality))
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
        
        self.measure(options: measureOnlyOnce){ // 2.13 sec
            images.forEach { image in
                _ =  try? XCTUnwrap(image.heicData(quality: heicQuality))
            }
        }
    }

    func testPerformance4JPGCompressionsConcurrent() async throws {
        let jpgQuality: CGFloat = 0.5
        let image = try XCTUnwrap(TestImage.image(size: .large))
        
        let images = Array(repeating: image, count: 4)
        
        self.measure(options: measureOnlyOnce) { // 0.517 sec
            let expectation = XCTestExpectation(description: "Concurrent JPG compression completed")

            Task {
                await images.concurrentForEach(withPriority: .background) { image in
                    _ = try? XCTUnwrap(image.jpgData(quality: jpgQuality))
                }
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 1.0)  // Adjust the timeout as necessary
        }
    }
    
    func testPerformance4JPGCompressionsSync() async throws {
        let jpgQuality: CGFloat = 0.5
        let image = try XCTUnwrap(TestImage.image(size: .large))
        
        let images = Array(repeating: image, count: 4)
        
        self.measure { // 1.854 sec
             images.forEach { image in
                 _ = try? XCTUnwrap(image.jpgData(quality: jpgQuality))
            }
        }
    }
}

