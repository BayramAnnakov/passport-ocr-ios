# DocumentsOCR

[![CI Status](http://img.shields.io/travis/Michael/DocumentsOCR.svg?style=flat)](https://travis-ci.org/Michael/DocumentsOCR)
[![Version](https://img.shields.io/cocoapods/v/DocumentsOCR.svg?style=flat)](http://cocoapods.org/pods/DocumentsOCR)
[![License](https://img.shields.io/cocoapods/l/DocumentsOCR.svg?style=flat)](http://cocoapods.org/pods/DocumentsOCR)
[![Platform](https://img.shields.io/cocoapods/p/DocumentsOCR.svg?style=flat)](http://cocoapods.org/pods/DocumentsOCR)

## Screenshots 

todo

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

This framework uses [TesseractOCRiOS](https://github.com/gali8/Tesseract-OCR-iOS) for text recognition of machine readable codes. To use DocumentsOCR, add tessdata/eng.traineddata to your app repository. 

## Installation

DocumentsOCR is [available](https://cocoapods.org/pods/DocumentsOCR) through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "DocumentsOCR"
```
## Usage

1) Create scanner instance with your UIViewController instance reference, which implemets PassportScannerDelegate protocol

```swift
    scanner = PassportScanner(containerVC: self, withDelegate: self)
```

2) Scanner instance can show view controller with camera and border

```swift
    scanner.showCameraViewController()
```

3) After take shoot button pressed, these delegate methods called: 

func willBeginScan(withImage image: UIImage)

```swift
    func didFinishScan(withInfo infoOpt: PassportInfo)
```

then if image was recognized successfull:

```swift
   func didFinishScan(withInfo infoOpt: PassportInfo)
```

else 

```swift
    func didFailedScan()
```



## Author

Michael, mmbabaev@gmail.com

## License

DocumentsOCR is available under the MIT license. See the LICENSE file for more info.

### TODO

- [ ] small screenshots
- [x] fix minor UI defects in example 
- [x] code refactoring
- [x] pod string for all versions (without using ~> version")
- [ ] check visa document recognitions
- [ ] unit tests for camera shoots
- [ ] take many pictures when press take shoot button, then choose best image for recognition
