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
            
            let overlayView = cameraOverlayView
            let width = self.imagePicker.view.frame.width
            let height = self.imagePicker.view.frame.height
            let frame = CGRect(x: 0, y: 0, width: width, height: height)
            overlayView.frame = frame
            
            imagePicker.modalPresentationStyle = .FullScreen
            viewController.presentViewController(imagePicker, animated: true, completion: {
                
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
        
        //let borderHeight = CGFloat(500)
        
//        let size1 = viewController.view.frame.size
//        let size2 = image.size
//        let w1 = size1.width
//        let w2 = size2.width
//        let h1 = size1.height
//        let h2 = (w2 * h1) / w1
//        let y = (h2 - borderHeight) / 2
//        let rect = CGRectMake(y, 0, borderHeight, image.size.width)
        
        
        let viewControllerSize = viewController.view.frame.size
        let vcWidth = viewControllerSize.width
        let vcHeight = viewControllerSize.height
        
        let cameraImageWidth = image.size.width
        let cameraImageHeight = (cameraImageWidth * vcHeight) / vcWidth
        
        let vcBorderHeight = cameraOverlayView.codeBorder.frame.size.height
        let borderHeight = (vcBorderHeight * cameraImageWidth) / vcWidth
       
        print("Border height: \(borderHeight)")
        
        let cameraImageY = (cameraImageHeight - borderHeight) / 2
        
        let rect = CGRectMake(cameraImageY, 0, borderHeight, image.size.width)
        
        let cropped = image.croppedImageWithSize(rect)
        self.receivedImage(cropped)
    
        print("Cropped: \(cropped.size)")
        
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
    
    private var cameraOverlayView: CameraOverlayView {
        let bundle = PodAsset.bundleForPod("DocumentsOCR")
        let cameraVC = CameraOverlayViewController(nibName: NibNames.cameraOverlayViewController, bundle: bundle!)
        let overlayView = cameraVC.view as! CameraOverlayView
        return overlayView
    }
}

