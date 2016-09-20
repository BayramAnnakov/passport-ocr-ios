//
//  TakePhotoViewController.swift
//  PassportOCR
//
//  Created by Михаил on 03.09.16.
//  Copyright © 2016 empatika. All rights reserved.
//

import UIKit
import Darwin
import DocumentsOCR

class PassportViewController: UITableViewController {

    var _imagePicker: UIImagePickerController!
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
        
        self.cameraImageView.contentMode = .ScaleAspectFit
        
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
        self.showCameraViewController()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
}

extension PassportViewController: PassportScanner {

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.didFinishingPickingImage(image)
    }
    var viewController: UIViewController {
        return self
    }

    var imagePicker: UIImagePickerController {
        set {
            _imagePicker = newValue
        }
        get {
            return _imagePicker
        }
    }
    
    func receivedImage(image: UIImage) {
        self.cameraImageView.image = image
    }
    
    func receivedInfo(infoOpt: PassportInfo?) {
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










