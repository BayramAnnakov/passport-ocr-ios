//
//  NSDateExtension.swift
//  PassportOCR
//
//  Created by Михаил on 06.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import Foundation

extension NSDate {
    static func dateFromPassportDateCode(code: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let year = code[0...1]
        let month = code[2...3]
        let day = code[4...5]

        return dateFormatter.dateFromString("19\(year)-\(month)-\(day)")
    }
    
    var stringDate: String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.stringFromDate(self)
    }
}