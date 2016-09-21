# DocumentsOCR

[![CI Status](http://img.shields.io/travis/Michael/DocumentsOCR.svg?style=flat)](https://travis-ci.org/Michael/DocumentsOCR)
[![Version](https://img.shields.io/cocoapods/v/DocumentsOCR.svg?style=flat)](http://cocoapods.org/pods/DocumentsOCR)
[![License](https://img.shields.io/cocoapods/l/DocumentsOCR.svg?style=flat)](http://cocoapods.org/pods/DocumentsOCR)
[![Platform](https://img.shields.io/cocoapods/p/DocumentsOCR.svg?style=flat)](http://cocoapods.org/pods/DocumentsOCR)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

This framework uses [TesseractOCRiOS](https://github.com/gali8/Tesseract-OCR-iOS) for text recognition of machine readable codes. To use DocumentsOCR, add tessdata/eng.traineddata to your app repository. 

## Installation

DocumentsOCR is [available](https://cocoapods.org/?q=Documents) through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "DocumentsOCR", '~> 0.3.0'
```
## Usage

Implement PassportScanner protocol in your custom class (see extension in Example project).

## Author

Michael, mmbabaev@gmail.com

## License

DocumentsOCR is available under the MIT license. See the LICENSE file for more info.

### TODO

- [ ] fix minor UI defects in example 
- [ ] code refactoring
- [ ] pod string for all versions (without using ~> version")
- [ ] check visa document recognitions
- [ ] unit tests
