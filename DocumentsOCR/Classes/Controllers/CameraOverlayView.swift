//
//  OverlayView.swift
//  PassportOCR
//
//  Created by Михаил on 03.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import UIKit

public class CameraOverlayView: UIView {
    
    @IBOutlet weak var codeBorder: UIView!
    
    var passportScanner: DocumentScanner!
    
    @IBAction func cancelButtonClicked(sender: UIButton) {
        passportScanner.viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func scanButtonClicked(sender: UIButton) {
        passportScanner.imagePicker.takePicture()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.opaque = false
    }
}
