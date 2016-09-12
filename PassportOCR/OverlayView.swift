//
//  OverlayView.swift
//  PassportOCR
//
//  Created by Михаил on 03.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import UIKit

protocol CameraOverlayViewDelegate{
    func didCancel(overlayView: CameraOverlayView)
    func didShoot(overlayView: CameraOverlayView)
}

class CameraOverlayView: UIView {

    @IBOutlet weak var passportBorder: UIView!
    @IBOutlet weak var codeBorder: UIView!
    
    var delegate: CameraOverlayViewDelegate!
    
    @IBAction func cancelButtonClicked(sender: UIButton) {
        delegate.didCancel(self)
    }
    
    @IBAction func scanButtonClicked(sender: UIButton) {
        delegate.didShoot(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.opaque = false
    }
}
