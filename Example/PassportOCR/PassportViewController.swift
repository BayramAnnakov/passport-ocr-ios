//
//  TakePhotoViewController.swift
//  PassportOCR
//
//  Created by Михаил on 03.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import UIKit
import Darwin
import MRProgress

class PassportViewController: UITableViewController, UINavigationControllerDelegate {

    var imagePicker: UIImagePickerController!
    var selectedTextField: PassportTextField!
    
    @IBOutlet weak var countryField: PassportTextField!
    @IBOutlet weak var surnameField: PassportTextField!
    @IBOutlet weak var nameField: PassportTextField!
    @IBOutlet weak var numberField: PassportTextField!
    @IBOutlet weak var nationalityField: PassportTextField!
    @IBOutlet weak var dobField: PassportTextField!
    @IBOutlet weak var sexField: PassportTextField!
    @IBOutlet weak var expiredDateField: PassportTextField!
    @IBOutlet weak var personalNumberField: PassportTextField!
    
    @IBOutlet weak var cameraImageView: UIImageView!
    
    let countries = Utils.stringFromTxtFile("CountryCodes")!.componentsSeparatedByString("\n")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set up country fields:
        
        let countryPicker = UIPickerView()
        countryPicker.delegate = self
        countryPicker.dataSource = self
        
        countryPicker.showsSelectionIndicator = true
        
        countryField.delegate = self
        nationalityField.delegate = self
        
        countryField.inputView = countryPicker
        nationalityField.inputView = countryPicker
        
        
        // Set up date fields:
        
        let datePicker = UIDatePicker()
        datePicker.addTarget(self, action: #selector(PassportViewController.datePickerValueChanged(_:)), forControlEvents: .ValueChanged)
        datePicker.datePickerMode = UIDatePickerMode.Date
        
        dobField.delegate = self
        expiredDateField.delegate = self
        
        dobField.inputView = datePicker
        expiredDateField.inputView = datePicker
    }
    
    func datePickerValueChanged(sender: UIDatePicker) {
        selectedTextField.text = sender.date.stringDate
    }
    
    @IBAction func cameraClicked(sender: UIBarButtonItem) {
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .Camera
            imagePicker.cameraCaptureMode = .Photo
            imagePicker.showsCameraControls = false
            
            imagePicker.delegate = self

            let cameraVC = CameraOverlayViewController(nibName: NibNames.cameraOverlayViewController, bundle: nil)
            let overlayView = cameraVC.view as! CameraOverlayView
            let width = self.imagePicker.view.frame.width
            let height = self.imagePicker.view.frame.height
            let frame = CGRect(x: 0, y: 0, width: width, height: height)
            overlayView.frame = frame
            
            imagePicker.modalPresentationStyle = .FullScreen
            presentViewController(imagePicker, animated: true, completion: {
                
                overlayView.passportBorder.layer.borderWidth = 2.0
                overlayView.passportBorder.layer.borderColor = UIColor.blackColor().CGColor
                
                overlayView.codeBorder.layer.borderWidth = 5.0
                overlayView.codeBorder.layer.borderColor = UIColor.redColor().CGColor
                
                overlayView.delegate = self
                
                self.imagePicker.cameraOverlayView = overlayView
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

extension PassportViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        NSLog("\(image.size)")
        
        // Magic numbers. Work for iphone 6 screen
        let rect = CGRectMake(3000, 0, 1000, 2448)
        let cropped = image.croppedImageWithSize(rect)
        
        self.cameraImageView.contentMode = .ScaleAspectFit
        self.cameraImageView.image = cropped

        dismissViewControllerAnimated(true, completion: nil)
        
//        let progressView = MRProgressOverlayView.showOverlayAddedTo(self.view.window, title: "Сканирование", mode: .Indeterminate, animated: true)
        
        NSOperationQueue().addOperationWithBlock {
            let info = PassportInfo(image: cropped, sender: self)
            dispatch_async(dispatch_get_main_queue()) {
                //progressView.dismiss(true)
                self.updateViewWithInfo(info)
            }
        }
    }
    
    private func updateViewWithInfo(infoOpt: PassportInfo?) {
        
        if let info = infoOpt {
            NSLog("Info: \(info)")
            
            countryField.text = info.countryCode
            surnameField.text = info.surname
            nameField.text = String(info.names)
            numberField.text = info.passportNumber
            nationalityField.text = info.nationalityCode
            dobField.text = info.dayOfBirth?.stringDate
            let sex: String = {
                switch info.sex {
                case .Female:
                    return "Женщина"
                case .Male:
                    return "Мужчина"
                default:
                    return "?"
                }
            }()
            sexField.text = sex
            expiredDateField.text = info.expiralDate?.stringDate
            personalNumberField.text = info.personalNumber
        }
        else {
            NSLog("Ошибка")
            self.showErrorAlert(withMessage: "Произошла ошибка распознования")
        }
    }
}

extension PassportViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        guard let passportField = textField as? PassportTextField else {
            NSLog("Ошибка: неверный тип текстового поля")
            return true
        }
        
        selectedTextField = passportField
        
        return true
    }
    
    // TODO: create mask for text fields
    
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//        guard let field = textField as? PassportTextField else {
//            NSLog("Ошибка: неверный тип текстового поля")
//            
//            
//            return false
//        }
//        
//        return false
//    }
}

extension PassportViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countries[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTextField?.text = countries[row][0...2]
    }
}

extension PassportViewController: CameraOverlayViewDelegate {
    
    func didShoot(overlayView: CameraOverlayView) {
        imagePicker.takePicture()
    }
    
    func didCancel(overlayView: CameraOverlayView) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension PassportViewController: G8TesseractDelegate {
    func progressImageRecognitionForTesseract(tesseract: G8Tesseract!) {
        NSLog("progress: \(tesseract.progress)")
    }
}










