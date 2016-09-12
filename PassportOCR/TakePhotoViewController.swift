//
//  TakePhotoViewController.swift
//  PassportOCR
//
//  Created by Михаил on 03.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import UIKit
import Darwin
import TesseractOCR
import MRProgress

class TakePhotoViewController: UIViewController, UINavigationControllerDelegate {

    var picker: UIImagePickerController!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var codeTextView: UITextView!
    @IBOutlet weak var mrcTextView: UITextView!
    @IBOutlet weak var cameraImageView: UIImageView!
    
    @IBAction func takePhotoClicked(sender: UIButton) {
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            picker = UIImagePickerController()
            picker.allowsEditing = false
            picker.sourceType = .Camera
            picker.cameraCaptureMode = .Photo
            picker.showsCameraControls = false
            
            picker.delegate = self
            
            let cameraVC = CameraOverlayViewController(nibName: NibNames.cameraOverlayViewController, bundle: nil)
            let overlayView = cameraVC.view as! CameraOverlayView
            let width = self.picker.view.frame.width
            let height = self.picker.view.frame.height
            let frame = CGRect(x: 0, y: 0, width: width, height: height)
            overlayView.frame = frame
            
            picker.modalPresentationStyle = .FullScreen
            presentViewController(picker, animated: true, completion: {
                
                overlayView.passportBorder.layer.borderWidth = 2.0
                overlayView.passportBorder.layer.borderColor = UIColor.blackColor().CGColor
                
                overlayView.codeBorder.layer.borderWidth = 5.0
                overlayView.codeBorder.layer.borderColor = UIColor.redColor().CGColor
                
                overlayView.delegate = self
                
                self.picker.cameraOverlayView = overlayView
            })
        }
        else {
            showErrorAlert(withMessage: "Камера не найдена")
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
}

extension TakePhotoViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        NSLog("\(image.size)")
        
        // Magic numbers. Work for iphone 6 screen
        let rect = CGRectMake(3000, 0, 1000, 2448)
        let cropped = image.croppedImageWithSize(rect)
        
        // let cropped = image
        
        self.cameraImageView.contentMode = .ScaleAspectFit
        self.cameraImageView.image = cropped
        self.mrcTextView.text = ""
        
        dismissViewControllerAnimated(true, completion: nil)
        
        self.activityIndicatorView.startAnimating()
        
        NSOperationQueue().addOperationWithBlock {
            let info = PassportInfo(image: cropped, sender: self)
            self.updateTextView(info)
        }
    }
    
    private func updateTextView(info: PassportInfo?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.activityIndicatorView.stopAnimating()
            
            if info != nil {
                self.mrcTextView.text = String(info)
            }
            else {
                self.mrcTextView.text = "Ошибка"
            }
        }
    }
}

extension TakePhotoViewController: CameraOverlayViewDelegate {
    func didShoot(overlayView: CameraOverlayView) {
        picker.takePicture()
    }
    
    func didCancel(overlayView: CameraOverlayView) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension TakePhotoViewController: G8TesseractDelegate {
    func progressImageRecognitionForTesseract(tesseract: G8Tesseract!) {
        NSLog("progress: \(tesseract.progress)")
    }
}










