//
//  ViewController.swift
//  PhotoTimeGepStamp
//
//  Created by Manish Kumar on 26/11/18.
//  Copyright © 2018 Innofied. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelForTimeStamp: UILabel!
    @IBOutlet weak var labelForgeoStamp: UILabel!
    
    var selectedImageInfo : [UIImagePickerController.InfoKey : Any]?
    var selectedImage : UIImage?
    var selectedImagePicker : UIImagePickerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


    @IBAction func resetButtonClicked(_ sender: UIButton) {
        imageView.image = nil
        labelForgeoStamp.text = "GeoStamp"
        labelForTimeStamp.text = "TimeStamp"
        selectedImageInfo = nil
        selectedImage = nil
        selectedImagePicker = nil
    }
    
    
    @IBAction func choosePhotoButtonClicked(_ sender: UIButton) {
        presentImagePickerActionSheet()
    }
    
    @IBAction func savePhotoClicked(_ sender: UIButton) {
        guard let selectedImageInfoData = selectedImageInfo, let selectedImageData = selectedImage, let selectedImagePickerData = selectedImagePicker else{
            
            return
        }
            
        if  selectedImagePickerData.sourceType == .camera {
            
            PHPhotoLibrary.shared().performChanges({
                let changeRequest = PHAssetChangeRequest.creationRequestForAsset(from: selectedImageData)
                changeRequest.creationDate = Date()
                changeRequest.location = CLLocation(latitude: 22.5851, longitude: 88.3468)
            }) { (success, error) in
                if success{
                    print("Changes saved")
                    //UIImageWriteToSavedPhotosAlbum(selectedImageData, self, nil, nil)
                }else{
                    if error != nil{
                        print("error :\(String(describing: error?.localizedDescription))")
                    }else{
                        print("FAILED..!!!!")
                    }
                }
            }
            
        } else if selectedImagePickerData.sourceType == .photoLibrary {
            
            if let asset = selectedImageInfoData[.phAsset] as? PHAsset{
                
                let editOperation = PHAssetEditOperation(rawValue: 1)
                if editOperation != nil{
                    if asset.canPerform(editOperation!){
                        
                        PHPhotoLibrary.shared().performChanges({
                            let changeRequest = PHAssetChangeRequest(for: asset)
                            changeRequest.creationDate = Date()
                            changeRequest.location = CLLocation(latitude: 22.5851, longitude: 88.3468)
                        }) { (success, error) in
                            if success{
                                print("Changes saved")
                            }else{
                                if error != nil{
                                    print("error :\(String(describing: error?.localizedDescription))")
                                }else{
                                    print("FAILED..!!!!")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
}



//MARK: - IMAGE PICKER CONTROLLER HELPERS
extension ViewController {
    
    fileprivate func presentImagePickerActionSheet() {
        // Presenting the Cameta Action Sheet
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        let photoLibraryButton = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.didReceiveTapOnPhotoLibraryButton()
            
        }
        let takePhotoButton = UIAlertAction(title: "Take Photo", style: .default) { (action) in
            self.didReceiveTapOnTakePhotoButton()
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (action) in

        }
        
        actionSheetController.addAction(photoLibraryButton)
        actionSheetController.addAction(takePhotoButton)
        actionSheetController.addAction(cancelButton)
        for action in actionSheetController.actions {
            action.setValue(UIColor(red: 51.0/255.0, green: 61.0/255.0, blue: 71.0/255.0, alpha: 1.0), forKey: "titleTextColor")
        }
        
        self.present(actionSheetController, animated: true) {
            
        }
        
        
    }
    
    // MARK: - Profile Picture Hanlders
    func didReceiveTapOnPhotoLibraryButton(){
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let imagePicker = UIImagePickerController()
            UINavigationBar.appearance().tintColor = UIColor(red: 51.0/255.0, green: 61.0/255.0, blue: 71.0/255.0, alpha: 1.0)//UIColor(red: 51, green: 61, blue: 71)
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            
        }
        
    }
    func didReceiveTapOnTakePhotoButton(){
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            UINavigationBar.appearance().tintColor = UIColor(red: 51.0/255.0, green: 61.0/255.0, blue: 71.0/255.0, alpha: 1.0)//UIColor(red: 51, green: 61, blue: 71)
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            
        }
    }
}
//MARK: - IMAGE PICKER CONTROLLER DELEGATE
extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        selectedImage = image
        selectedImageInfo = info
        selectedImagePicker = picker
        

        if picker.sourceType == .camera {

            if let assetDictionary = info[.mediaMetadata] as? NSDictionary{
                if let tiffDic = assetDictionary["{TIFF}"] as? [String: AnyObject]{
                    labelForTimeStamp.text = tiffDic["DateTime"] as? String
                }
            }
            if LocationManager.shared.currentLocation != nil{
                labelForgeoStamp.text = "\(LocationManager.shared.currentLocation!.latitude), \((LocationManager.shared.currentLocation!.longitude))"
            }else{
                labelForgeoStamp.text = "Location not found"
            }

        }else if picker.sourceType == .photoLibrary {

            if let asset = info[.phAsset] as? PHAsset{

                let location = asset.location
                let date = asset.creationDate

                if date != nil{
                    labelForTimeStamp.text = "\(date!)"
                }

                if location != nil{
                    labelForgeoStamp.text = "\(location!.coordinate.latitude), \(location!.coordinate.longitude)"
                }
            }
        }
        
        
        imageView.image = image
        dismiss(animated: true, completion: nil) //5
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil) //5
    }
    
}

extension ViewController: UINavigationControllerDelegate {
    
}

