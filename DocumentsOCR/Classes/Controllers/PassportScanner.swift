//
//  PassportScannerViewController.swift
//  Pods
//
//  Created by Михаил on 19.09.16.
//
//

import UIKit
import TesseractOCR
import PodAsset

public protocol PassportScanner: UINavigationControllerDelegate, UIImagePickerControllerDelegate, G8TesseractDelegate
{
    var imagePicker: UIImagePickerController { set get }
    var viewController: UIViewController { get }
    
    func receivedImage(image: UIImage)
    func receivedInfo(infoOpt: PassportInfo?)
}

extension PassportScanner {
    
    public func showCameraViewController() {
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .Camera
            imagePicker.cameraCaptureMode = .Photo
            imagePicker.showsCameraControls = false
            
            imagePicker.delegate = self
            
            let bundle = PodAsset.bundleForPod("DocumentsOCR")
            let cameraVC = CameraOverlayViewController(nibName: NibNames.cameraOverlayViewController, bundle: bundle!)
            let overlayView = cameraVC.view as! CameraOverlayView
            let width = self.imagePicker.view.frame.width
            let height = self.imagePicker.view.frame.height
            let frame = CGRect(x: 0, y: 0, width: width, height: height)
            overlayView.frame = frame
            
            imagePicker.modalPresentationStyle = .FullScreen
            viewController.presentViewController(imagePicker, animated: true, completion: {
                
                overlayView.passportBorder.layer.borderWidth = 2.0
                overlayView.passportBorder.layer.borderColor = UIColor.blackColor().CGColor
                
                overlayView.codeBorder.layer.borderWidth = 5.0
                overlayView.codeBorder.layer.borderColor = UIColor.redColor().CGColor
                
                overlayView.passportScanner = self
                
                self.imagePicker.cameraOverlayView = overlayView
            })
        }
        else {
            viewController.showErrorAlert(withMessage: "Камера не найдена")
        }
    }

    public func didFinishingPickingImage(image: UIImage) {
        
        NSLog("\(image.size)")
        
        // Magic numbers. Work for iphone 6 screen
        let rect = CGRectMake(3000, 0, 1000, 2448)
        let cropped = image.croppedImageWithSize(rect)
        
        self.receivedImage(cropped)
        
        viewController.dismissViewControllerAnimated(true, completion: nil)
        
        //        let progressView = MRProgressOverlayView.showOverlayAddedTo(self.view.window, title: "Сканирование", mode: .Indeterminate, animated: true)
        
        NSOperationQueue().addOperationWithBlock {
            let info = PassportInfo(image: cropped, sender: self)
            dispatch_async(dispatch_get_main_queue()) {
                //progressView.dismiss(true)
                self.receivedInfo(info)
            }
        }
    }
}

