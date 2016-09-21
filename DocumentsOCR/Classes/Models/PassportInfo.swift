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

public enum Gender { ///gender
    case Male, Female, Unknown
}

/// Struct-container for recognition fields of passport machine readable code

public struct PassportInfo {
    
    /// issuing country or organization (ISO 3166-1 alpha-3 code with modifications)
    public let issuingCountryCode: String
    
    /// lastname
    public let lastname: String
    
    /// name, firstName + ...
    public let name: String
    
    /// passport number
    public let passportNumber: String
    
    /// nationality (ISO 3166-1 alpha-3 code with modifications)
    public let nationalityCode: String
    
    /// date of birth
    public let dateOfBirth: NSDate?
    
    /// gender
    public let gender: Gender
    
    /// expiration date of passport
    public let expiralDate: NSDate?
    
    /// personal number (may be used by the issuing country as it desires)
    public let personalNumber: String
    
    /// check digits
    public let checkDigits: [String]
    
    private static let bundle = PodAsset.bundleForPod("DocumentsOCR")
    private static let passportPattern: String! = Utils.stringFromTxtFile("passportPattern", inBundle: bundle)
    
    init?(recognizedText text: String) {
        
        var regex: NSRegularExpression!
        
        do {
            regex = try NSRegularExpression(pattern: PassportInfo.passportPattern, options: [])
        }
        catch {
            NSLog("error pattern")
            return nil
        }
        
        let range = NSRange(location: 0, length: text.characters.count)
        if let result = regex.firstMatchInString(text, options: [], range: range) {
            NSLog("\(result.components)")
            
            issuingCountryCode = result.group(atIndex: 4, fromSource: text)
            lastname = result.group(atIndex: 6, fromSource: text)
            name = result.group(atIndex: 7, fromSource: text).stringByReplacingOccurrencesOfString("<", withString: " ")
            passportNumber = result.group(atIndex: 9, fromSource: text)
            nationalityCode = result.group(atIndex: 11, fromSource: text)
            
            let dayOfBirthCode = result.group(atIndex: 12, fromSource: text)
            dateOfBirth = NSDate.dateFromPassportDateCode("19" + dayOfBirthCode)
            
            let genderLetter = result.group(atIndex: 17, fromSource: text)
            switch genderLetter {
            case "F":
                gender = .Female
            case "M":
                gender = .Male
            default:
                NSLog("Error: unknown sex \(genderLetter)")
                gender = .Unknown
            }
            
            let expiralDateCode = result.group(atIndex: 18, fromSource: text)
            expiralDate = NSDate.dateFromPassportDateCode("20" + expiralDateCode)
            
            personalNumber = result.group(atIndex: 23, fromSource: text)
            
            checkDigits = [
                result.group(atIndex: 10, fromSource: text),
                result.group(atIndex: 16, fromSource: text),
                result.group(atIndex: 22, fromSource: text),
                result.group(atIndex: 24, fromSource: text),
                result.group(atIndex: 25, fromSource: text),
            ]
        }
        else {
            NSLog("Error: no match result")
            return nil
        }
    }
    
    init?(image: UIImage, tesseractDelegate: G8TesseractDelegate?) {
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
            NSLog("RECOGNIZED: \(recognizedText)")
            
            let mrCode = recognizedText.stringByReplacingOccurrencesOfString(" ", withString: "")
        
            self.init(recognizedText: mrCode)
        }
        else {
            return nil
        }
    }
}











