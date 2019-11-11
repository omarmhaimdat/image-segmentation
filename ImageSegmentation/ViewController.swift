//
//  ViewController.swift
//  ImageSegmentation
//
//  Created by M'haimdat omar on 04-11-2019.
//  Copyright © 2019 M'haimdat omar. All rights reserved.
//

import UIKit
import Vision

let screenWidth = UIScreen.main.bounds.width

class SegmentationResultMLMultiArray {
    let mlMultiArray: MLMultiArray
    let segmentationmapWidthSize: Int
    let segmentationmapHeightSize: Int
    
    init(mlMultiArray: MLMultiArray) {
        self.mlMultiArray = mlMultiArray
        self.segmentationmapWidthSize = mlMultiArray.shape[0].intValue
        self.segmentationmapHeightSize = mlMultiArray.shape[1].intValue
    }
    
    subscript(colunmIndex: Int, rowIndex: Int) -> NSNumber {
        let index = colunmIndex*(segmentationmapHeightSize) + rowIndex
        return mlMultiArray[index]
    }
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var request: VNCoreMLRequest?
    var visionModel: VNCoreMLModel?

    let segmentationModel = DeepLabV3()
    
    let logo: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "default").resized(newSize: CGSize(width: screenWidth, height: screenWidth)))
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let upload: BtnPleinLarge = {
        let button = BtnPleinLarge()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonToUpload(_:)), for: .touchUpInside)
        button.setTitle("Upload", for: .normal)
        let icon = UIImage(named: "upload")?.resized(newSize: CGSize(width: 50, height: 50))
        button.addRightImage(image: icon!, offset: 30)
        button.backgroundColor = #colorLiteral(red: 0.1399718523, green: 0.4060479403, blue: 0.3119114339, alpha: 1)
        button.layer.borderColor = #colorLiteral(red: 0.1399718523, green: 0.4060479403, blue: 0.3119114339, alpha: 1)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowColor = #colorLiteral(red: 0.1399718523, green: 0.4060479403, blue: 0.3119114339, alpha: 1)
        button.layer.shadowOffset = CGSize(width: 1, height: 5)
        button.layer.cornerRadius = 10
        button.layer.shadowRadius = 8
        button.layer.masksToBounds = true
        button.clipsToBounds = false
        button.contentHorizontalAlignment = .left
        button.layoutIfNeeded()
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        button.titleEdgeInsets.left = 0
        
        return button
    }()
    
    let camera: BtnPleinLarge = {
        let button = BtnPleinLarge()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonToCamera(_:)), for: .touchUpInside)
        button.setTitle("Camera", for: .normal)
        let icon = UIImage(named: "camera")?.resized(newSize: CGSize(width: 50, height: 50))
        button.addRightImage(image: icon!, offset: 30)
        button.backgroundColor = #colorLiteral(red: 0.3344218731, green: 0.7652652264, blue: 0.5346129537, alpha: 1)
        button.layer.borderColor = #colorLiteral(red: 0.3344218731, green: 0.7652652264, blue: 0.5346129537, alpha: 1)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowColor = #colorLiteral(red: 0.3344218731, green: 0.7652652264, blue: 0.5346129537, alpha: 1)
        button.layer.shadowOffset = CGSize(width: 1, height: 5)
        button.layer.cornerRadius = 10
        button.layer.shadowRadius = 8
        button.layer.masksToBounds = true
        button.clipsToBounds = false
        button.contentHorizontalAlignment = .left
        button.layoutIfNeeded()
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        button.titleEdgeInsets.left = 0
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        addSubviews()
        setupLayout()
        
    }
    
    func addSubviews() {
        view.addSubview(logo)
        view.addSubview(upload)
        view.addSubview(camera)
    }
    
    func setupLayout() {
        
        logo.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        logo.topAnchor.constraint(equalTo: self.view.safeTopAnchor, constant: 20).isActive = true
        
        upload.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        upload.widthAnchor.constraint(equalToConstant: view.frame.width - 40).isActive = true
        upload.heightAnchor.constraint(equalToConstant: 80).isActive = true
        upload.bottomAnchor.constraint(equalTo: camera.topAnchor, constant: -40).isActive = true
        
        camera.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        camera.widthAnchor.constraint(equalToConstant: view.frame.width - 40).isActive = true
        camera.heightAnchor.constraint(equalToConstant: 80).isActive = true
        camera.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120).isActive = true
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if (info[UIImagePickerController.InfoKey.editedImage] as? UIImage) != nil {
            
            if let image = info[.editedImage] as? UIImage {
                
                let outputVC = OutputViewController()
                outputVC.inputImage.image = image
                outputVC.cgImage = image.cgImage
                dismiss(animated: true, completion: nil)
                self.present(outputVC, animated: true, completion: nil)
                
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @objc func buttonToUpload(_ sender: BtnPleinLarge) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @objc func buttonToCamera(_ sender: BtnPleinLarge) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
}
