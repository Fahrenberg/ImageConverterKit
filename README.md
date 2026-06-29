# ImageCompressionKit
![](https://img.shields.io/badge/iOS%20:-15-blue)
![](https://img.shields.io/badge/macOS%20:-11_(BigSur)%20|%20MacCatalyst-green)
![GitHub Release](https://img.shields.io/github/v/release/Fahrenberg/ImageCompressionKit)
![GitHub last commit](https://img.shields.io/github/last-commit/Fahrenberg/ImageCompressionKit)


## ImageCompressor

Compresses image `Data` using device/platfrom independent ImageIO.

| Compression<br> Method | Default<br> Compression<br> Quality | Usage |
| ------------------ | :------------------------------: | ----- |
| HEIC | `0.75` | `.heicData(from: imageData)` |
| JPEG | `0.65` | `.jpegData(from: imageData)` |

Notes:
- The default HEIC compression quality (`0.75`) matches the behavior of the native `UIImage.heicData()` API introduced in iOS 17.
- Use HEIC only with [supported devices for HEIC](https://support.apple.com/en-us/HT207022). Very efficient but slower to compress than jpg.

## PlatformImage+Compression

Convenience wrapper to compress `PlatformImage` directly into a `Data`, uses [PlatformImage](https://github.com/Fahrenberg/Extensions?tab=readme-ov-file#platformimage) typealias for UIImage or NSImage. See [Extensions](https://github.com/Fahrenberg/Extensions?tab=readme-ov-file#swift---extensions---library)

### HEIC Compression

Notes: 
- For compress multiple images use **sync** not async, it's faster...
- Compress an UIImage or NSImage (Extension) to data.
- Very efficient but slower to compress than jpg

#### Compress to  +/- 10% of askedMaxSize
```swift
public func heicDataCompression(askedMaxSize: UInt64 = .max) -> Data? 
```
#### Compress by setting compressionQuality
```swift
public func heicDataCompression(compressionQuality: CGFloat) -> Data?
```


### JPG Compression

Notes:
- For compress multiple images use `Task {}` async (50% faster) rather than sync.
- Fallback solution to compress UIImage or NSImage.
- Use it if HEIC Compressor not available (old iPhones).
- Less 10x efficient than HEIC compression. Faster to compress. 

#### Compress to  +/- 10% of askedMaxSize
```swift
public func jpgDataCompression(askedMaxSize: UInt64 = .max) -> Data? 
```
#### Compress by setting compressionQuality
```swift
public func jpgDataCompression(compressionQuality: CGFloat) -> Data?
```

See [different approaches](https://stackoverflow.com/questions/29726643/how-to-compress-of-reduce-the-size-of-an-image-before-uploading-to-parse-as-pffi)


### Resize Image

Resize original image to `CGSize`. Does not compress image.</br>
Optional dpi and image alignment within targetSize box.

```swift
public func resized(to targetSize: CGSize,
                        dpi: CGFloat = 72.0,
                        alignment: ImageAlignment = .center) -> PlatformImage?
```

