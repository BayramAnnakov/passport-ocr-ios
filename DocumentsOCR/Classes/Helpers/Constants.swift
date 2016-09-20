//
//  Constants.swift
//  PassportOCR
//
//  Created by Михаил on 03.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import Foundation

struct NibNames {
    static let cameraOverlayViewController = "CameraOverlayViewController"
}

struct Constants {
    
    static let alphabet = Constants.getAlphabet()
    
    private static func getAlphabet() -> String {
        let aScalars = "a".unicodeScalars
        let aCode = aScalars[aScalars.startIndex].value
        
        var result = ""
        
        for i: UInt32 in (0..<26) {
            result.append(Character(UnicodeScalar(aCode + i)))
        }
    
        return result
    }
}



//
//let viewControllerSize = viewController.view.frame.size
//let vcWidth = viewControllerSize.width
//let vcHeight = viewControllerSize.height
//
//let cameraImageWidth = image.size.width
//let cameraImageHeight = (cameraImageWidth * vcWidth) / vcWidth
//
//let vcBorderHeight = cameraOverlayView.codeBorder.frame.size.height
////let borderHeight = (vcBorderHeight * cameraImageWidth) / vcWidth
//let borderHeight = CGFloat(500)
//print("Border height: \(borderHeight)")
//
//let cameraImageY = (cameraImageHeight - borderHeight) / 2
//
//let rect = CGRectMake(cameraImageY, 0, borderHeight, image.size.width)
//
//let cropped = image.croppedImageWithSize(rect)
//self.receivedImage(cropped)
//
//



