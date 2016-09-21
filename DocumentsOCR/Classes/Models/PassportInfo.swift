//
//  PassportInfo.swift
//  PassportOCR
//
//  Created by Михаил on 05.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import Foundation
import TesseractOCR
import PodAsset

public enum Sex {
    case Male, Female, Unknown
}

public struct PassportInfo {
    private static let bundle = PodAsset.bundleForPod("DocumentsOCR")
    static let passportPattern: String! = Utils.stringFromTxtFile("passportPattern", inBundle: bundle)
    
    public let countryCode: String
    public let surname: String
    public let names: [String]
    public let passportNumber: String
    
    public let nationalityCode: String
    public let dayOfBirth: NSDate?
    public let sex: Sex
    public let expiralDate: NSDate?
    public let personalNumber: String
    
//    let checkDigit1: Int
//    let checkDigit2: Int
//    let checkDigit3: Int
//    let checkDigit4: Int
    
    public init?(recognizedText text: String) {
        
        var regex: NSRegularExpression!
        
        do {
            regex = try NSRegularExpression(pattern: PassportInfo.passportPattern, options: [])
        }
        catch {
            print("error pattern")
            return nil
        }
        
        let range = NSRange(location: 0, length: text.characters.count)
        if let result = regex.firstMatchInString(text, options: [], range: range) {
            NSLog("\(result.components)")
            
            countryCode = result.group(atIndex: 4, fromSource: text)
            surname = result.group(atIndex: 6, fromSource: text)
            names = result.group(atIndex: 7, fromSource: text).componentsSeparatedByString("<")
            passportNumber = result.group(atIndex: 9, fromSource: text)
            nationalityCode = result.group(atIndex: 11, fromSource: text)
            
            let dayOfBirthCode = result.group(atIndex: 12, fromSource: text)
            dayOfBirth = NSDate.dateFromPassportDateCode(dayOfBirthCode)
            
            let sexLetter = result.group(atIndex: 17, fromSource: text)
            switch sexLetter {
            case "F":
                sex = .Female
            case "M":
                sex = .Male
            default:
                NSLog("Error: unknown sex \(sexLetter)")
                sex = .Unknown
            }
            
            let expiralDateCode = result.group(atIndex: 18, fromSource: text)
            expiralDate = NSDate.dateFromPassportDateCode(expiralDateCode)
            
            personalNumber = result.group(atIndex: 23, fromSource: text)
        }
        else {
            NSLog("Error: no match result")
            return nil
        }
    }
    
    public init?(image: UIImage, tesseractDelegate: G8TesseractDelegate?) {
        let tesseract = G8Tesseract(language: "eng")
        
        if tesseractDelegate != nil {
            tesseract.delegate = tesseractDelegate!
        }
        
        tesseract.image = image
        var whiteList = Constants.alphabet.uppercaseString
        whiteList.appendContentsOf("<>1234567890")
        tesseract.charWhitelist = whiteList
        tesseract.setVariableValue("FALSE", forKey: "x_ht_quality_check")
        
        tesseract.recognize()
        
        if let recognizedText = tesseract.recognizedText {
            print("RECOGNIZED: \(recognizedText)")
            
            let mrCode = recognizedText.stringByReplacingOccurrencesOfString(" ", withString: "")
            print(mrCode)
            self.init(recognizedText: mrCode)
        }
        else {
            self.init(recognizedText: "")
        }
    }
}











