# BencodeKit
This project's main intent is to allow you to deserialise and reserialise .torrent files natively in Swift without having to worry about all the null pointer and potential segfault stuff that comes with using a C library.

BencodeKit uses Apple's native CryptoKit framework for SHA1 hashing, eliminating the need for third-party dependencies.

# Usage

## Swift Package Manager

Add BencodeKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/MonadicConsulting/BencodeKit.git", from: "1.0.0")
]
```

**Requirements:**
- macOS 10.15+
- iOS 13.0+
- tvOS 13.0+
- watchOS 6.0+

## Carthage

Add the following to your Cartfile:
```
github "MonadicConsulting/BencodeKit"
```
