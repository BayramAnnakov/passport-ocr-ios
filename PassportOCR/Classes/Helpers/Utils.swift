//
//  Utils.swift
//  PassportOCR
//
//  Created by Михаил on 15.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import Foundation

public class Utils {
    static func stringFromTxtFile(fileName: String) -> String? {
        let filePath = NSBundle.mainBundle().pathForResource(fileName, ofType: "txt")
        let contentData = NSFileManager.defaultManager().contentsAtPath(filePath!)
        return NSString(data: contentData!, encoding: NSUTF8StringEncoding) as? String
    }
}