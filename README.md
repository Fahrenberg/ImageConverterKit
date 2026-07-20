# ImageConverterKit

![](https://img.shields.io/badge/iOS-15-blue)
![](https://img.shields.io/badge/macOS-11_(BigSur)_|_MacCatalyst-green)
![GitHub Release](https://img.shields.io/github/v/release/Fahrenberg/ImageCompressionKit)
![GitHub last commit](https://img.shields.io/github/last-commit/Fahrenberg/ImageCompressionKit)

ImageCompressionKit is a lightweight, platform-independent image conversion library built on top of Apple's **ImageIO** framework.

It provides:

- Image format conversion
- HEIC, JPEG and PNG encoding
- Image resizing
- Image alignment
- Background filling
- Target file size compression
- Image type detection

The library operates directly on `Data` and `CGImage`, making it independent from UIKit and AppKit. Convenience APIs for `PlatformImage` (`UIImage` / `NSImage`) are included.

---

# Quick Start

The following example demonstrates the most common workflow:

1. Resize an image while preserving its aspect ratio.
2. Fill any remaining space with a white background.
3. Center the image.
4. Convert it to HEIC.
5. Compress it to approximately **300 KB**.

```swift
let resized = imageData.resizeImage(
    to: CGSize(width: 1200, height: 800),
    background: .white,
    alignment: .center
)

let heic = resized?.heicData(
    askedMaxSize: 300_000
)
```

Or, starting from a `PlatformImage`:

```swift
let resized = image.resized(
    to: CGSize(width: 1200, height: 800),
    alignment: .center
)

let heic = resized?.heicData(
    askedMaxSize: 300_000
)
```

In just a few lines, ImageCompressionKit can resize an image, apply a background, preserve its aspect ratio, convert it to a different format, and optimize it for a target file size.

---

# Features

- ✅ Platform independent (ImageIO)
- ✅ HEIC, JPEG and PNG conversion
- ✅ Resize images while preserving aspect ratio
- ✅ Left, center or right image alignment
- ✅ Transparent, white, black or custom background
- ✅ Preserve the original image format when resizing
- ✅ Compress images to an approximate target file size
- ✅ Automatic alpha removal for JPEG and HEIC
- ✅ Detect image formats using `UTType`

---

# Data Conversion

Convert image `Data` into another image format.

| Method | Default Quality | Description |
|---------|:---------------:|-------------|
| `.heicData()` | `0.75` | Converts to HEIC |
| `.jpgData()` | `0.65` | Converts to JPEG |
| `.pngData()` | Lossless | Converts to PNG |

Custom quality:

```swift
imageData.heicData(quality: 0.85)
imageData.jpgData(quality: 0.50)
```

Compress to target size:

```swift
imageData.heicData(askedMaxSize: 300_000)
imageData.jpgData(askedMaxSize: 300_000)
```

---

# Resize Images

```swift
let resized = imageData.resizeImage(
    to: CGSize(width: 1200, height: 800)
)
```

The resized image automatically preserves the original image format.

---

# ImageBackground

Supported backgrounds:

```swift
.transparent
.white
.black
.color(CGColor)
```

Example:

```swift
let resized = imageData.resizeImage(
    to: targetSize,
    background: .white
)
```

---

# ImageAlignment

```swift
.left
.center
.right
```

Example:

```swift
let resized = imageData.resizeImage(
    to: targetSize,
    alignment: .left
)
```

---

# PlatformImage Convenience API

```swift
image.heicData()
image.jpgData()
image.pngData()

image.heicData(quality: 0.8)
image.jpgData(quality: 0.6)

image.heicData(askedMaxSize: 500_000)
image.jpgData(askedMaxSize: 500_000)

image.resized(
    to: CGSize(width: 800, height: 600),
    alignment: .center
)
```

---

# Detect Image Types

```swift
let type = imageData.imageType
```

Convenience properties:

```swift
type?.isImage
type?.isHEICImage
type?.isJPGImage
type?.isPNGImage
```

---

# Alpha Handling

JPEG and HEIC do not support transparency. ImageCompressionKit automatically removes alpha channels when required before encoding. PNG preserves transparency.

---

# Requirements

- iOS 15+
- macOS 11+
- Mac Catalyst

---

# Implementation

The library is built on Apple's **ImageIO** and **CoreGraphics** frameworks. Its core APIs operate on `Data` and `CGImage`, while `PlatformImage` extensions provide convenient UIKit/AppKit integration.
