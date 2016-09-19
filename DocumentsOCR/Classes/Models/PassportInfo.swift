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
    
    
    
    public init?(machineReadableCode code: String) {
        
        var regex: NSRegularExpression!
        
        do {
            regex = try NSRegularExpression(pattern: PassportInfo.passportPattern, options: [])
        }
        catch {
            print("error pattern")
            return nil
        }
        
        let range = NSRange(location: 0, length: code.characters.count)
        if let result = regex.firstMatchInString(code, options: [], range: range) {
            NSLog("\(result.components)")
            
            countryCode = result.group(atIndex: 4, fromSource: code)
            surname = result.group(atIndex: 6, fromSource: code)
            names = result.group(atIndex: 7, fromSource: code).componentsSeparatedByString("<")
            passportNumber = result.group(atIndex: 9, fromSource: code)
            nationalityCode = result.group(atIndex: 11, fromSource: code)
            
            let dayOfBirthCode = result.group(atIndex: 12, fromSource: code)
            dayOfBirth = NSDate.dateFromPassportDateCode(dayOfBirthCode)
            
            let sexLetter = result.group(atIndex: 17, fromSource: code)
            switch sexLetter {
            case "F":
                sex = .Female
            case "M":
                sex = .Male
            default:
                NSLog("Error: unknown sex \(sexLetter)")
                sex = .Unknown
            }
            
            let expiralDateCode = result.group(atIndex: 18, fromSource: code)
            expiralDate = NSDate.dateFromPassportDateCode(expiralDateCode)
            
            personalNumber = result.group(atIndex: 23, fromSource: code)
        }
        else {
            NSLog("Error: no match result")
            return nil
        }
    }
    
    public init?(image: UIImage, sender: G8TesseractDelegate?) {
        let tesseract = G8Tesseract(language: "eng")
        
        if sender != nil {
            tesseract.delegate = sender!
        }
        
        tesseract.image = image
        var whiteList = Constants.alphabet.uppercaseString
        whiteList.appendContentsOf("<>1234567890")
        tesseract.charWhitelist = whiteList
        
        tesseract.recognize()
        
        if let recognizedText = tesseract.recognizedText {
            print("RECOGNIZED: \(recognizedText)")
            
            let mrCode = tesseract.recognizedText.stringByReplacingOccurrencesOfString(" ", withString: "")
            print(mrCode)
            self.init(machineReadableCode: mrCode)
        }
        else {
            self.init(machineReadableCode: "")
        }
    }
}











