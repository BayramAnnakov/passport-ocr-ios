//
//  Utils.swift
//  PassportOCR
//
//  Created by Михаил on 15.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import Foundation

public class Utils {
    public static func stringFromTxtFile(fileName: String, inBundle bundle: NSBundle = NSBundle.mainBundle()) -> String? {
        let filePath = bundle.pathForResource(fileName, ofType: "txt")
        let contentData = NSFileManager.defaultManager().contentsAtPath(filePath!)
        return NSString(data: contentData!, encoding: NSUTF8StringEncoding) as? String
    }
    
//    static var undle: NSBundle {
////        let podBundle = NSBundle(forClass: Utils.self)
////        
////        let bundleURL = podBundle.URLForResource("DocumentsOCR", withExtension: "bundle")
////        return NSBundle(URL: bundleURL!)!
//        
//        let frameworkBundle = NSBundle(forClass: Utils.self)
//        let bundleURL = frameworkBundle.resourceURL?.URLByAppendingPathComponent("DocumetsOCR.bundle")
//        let resourceBundle = NSBundle(URL: bundleURL!)
//        
//        return resourceBundle!
//    }
    
    public static func bundleForPod(podName: String) -> NSBundle? {
        for bundle in NSBundle.allBundles() {
            if let bundlePath = bundle.pathForResource(podName, ofType: "bundle") {
                return NSBundle(path: bundlePath)
            }
        }
        
//        for bundle in NSBundle.allBundles() {
//            let bundle
//        }
//        
//        // search all frameworks
//        for (NSBundle* bundle in [NSBundle allBundles]) {
//            NSArray* bundles = [self recursivePathsForResourcesOfType:@"bundle" name:podName inDirectory:[bundle bundlePath]];
//            if (bundles.count > 0) {
//                return bundles.firstObject;
//            }
//        }
//        // some pods do not use "resource_bundles"
//        // please check the pod's podspec
        return nil;
    }
}