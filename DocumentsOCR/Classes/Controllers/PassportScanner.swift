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

/// The delegate of a PassportScanenr object must adopt the PassportScanner protocol. Methods of protocol allow use result of passport machine readable code recognition, handle errors if something went wrong. In addition, this protocol inherit G8TesseractDelegate protocol, so you can handle progress of image recognition (optional).
public protocol PassportScannerDelegate: G8TesseractDelegate {
    
    /// Tells the delegate that user press take photo button, contains reference to cropped image from camera shoot
    func willBeginScan(withImage image: UIImage)
    
    /// Tells the delegate that scanner finished to recognize machine readable code from camera image and translate it into PassportInfo struct
    func didFinishScan(withInfo info: PassportInfo)
    
    /// Tells the delegate that some error happened
    func didFailed(error: NSError)
}

public class PassportScanner: NSObject {
    
    var imagePicker = UIImagePickerController()
    
    /// View controller, which will present camera image picker for passport code
    public var viewController: UIViewController!
    
    /// The object that acts as the delegate of the passport scanner
    public var delegate: PassportScannerDelegate!
    
    /**
     Initializes and returns a new passport scanner with the provided container view controller and delegate
     
     - Parameters:
     - containerVC: View controller, which will present camera image picker for passport code
     - delegate: The object that acts as the delegate of the passport scanner
     
     - Returns: ready-to-use passport scanner instance
     */

    public init(containerVC: UIViewController, withDelegate delegate: PassportScannerDelegate) {
        self.delegate = delegate
        self.viewController = containerVC
    }
    
    /// Present view controller with camera and border for passport code
    
    public func presentCameraViewController() {
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
    
    private var cameraOverlayView: CameraOverlayView {
        let bundle = PodAsset.bundleForPod("DocumentsOCR")
        let cameraVC = CameraOverlayViewController(nibName: NibNames.cameraOverlayViewController, bundle: bundle!)
        let overlayView = cameraVC.view as! CameraOverlayView
        return overlayView
    }
}

extension PassportScanner: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        viewController.dismissViewControllerAnimated(true, completion: nil)
        
        let cropped = cropImage(image)
        delegate.willBeginScan(withImage: cropped)
        
        NSOperationQueue().addOperationWithBlock {
            let infoOpt = PassportInfo(image: cropped, tesseractDelegate: self.delegate)
            
            dispatch_async(dispatch_get_main_queue()) {
                if let info = infoOpt {
                    self.delegate.didFinishScan(withInfo: info)
                }
                else {
                    let error = NSError(domain: ErrorDomains.RecognitionFailed, code: 1, userInfo: [
                        NSLocalizedDescriptionKey : "Scanner unnable recognize passport machine readable code from camera picture"
                        ])
                    self.delegate.didFailed(error)
                }
            }
        }
    }
    
    private func cropImage(image: UIImage) -> UIImage {
        let viewControllerSize = viewController.view.frame.size
        let vcWidth = viewControllerSize.width
        let vcHeight = viewControllerSize.height
        
        let cameraImageWidth = image.size.width
        let cameraImageHeight = (cameraImageWidth * vcHeight) / vcWidth
        
        let vcBorderHeight = cameraOverlayView.codeBorder.frame.size.height
        let borderHeight = (vcBorderHeight * cameraImageWidth) / vcWidth
        
        let cameraImageY = (cameraImageHeight - borderHeight) / 2
        
        let rect = CGRectMake(cameraImageY, 0, borderHeight, image.size.width)
        return image.croppedImageWithSize(rect)
    }
}

