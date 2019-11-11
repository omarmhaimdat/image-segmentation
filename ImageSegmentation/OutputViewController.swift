//
//  OutputViewController.swift
//  Apple_VS_Google
//
//  Created by M'haimdat omar on 07-10-2019.
//  Copyright © 2019 M'haimdat omar. All rights reserved.
//

import UIKit
import Vision

class OutputViewController: UIViewController {
    
    var request: VNCoreMLRequest?
    var visionModel: VNCoreMLModel?
    var cgImage: CGImage?
    
    let segmentationModel = DeepLabV3()
    
    let inputImage: UIImageView = {
        let image = UIImageView(image: UIImage())
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    let dissmissButton: BtnPleinLarge = {
        let button = BtnPleinLarge()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonToDissmiss(_:)), for: .touchUpInside)
        button.setTitle("Done", for: .normal)
        button.backgroundColor = .systemRed
        button.layer.borderColor = UIColor.systemRed.cgColor
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        addSubviews()
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpModel()
        self.predict(with: self.cgImage!)
    }
    
    func setUpModel() {
        if let visionModel = try? VNCoreMLModel(for: segmentationModel.model) {
            self.visionModel = visionModel
            request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
            request?.imageCropAndScaleOption = .centerCrop
        } else {
            fatalError()
        }
    }
    
    func addSubviews() {
        view.addSubview(dissmissButton)
        view.addSubview(inputImage)
    }
    
    func setupLayout() {
        
        dissmissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dissmissButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        dissmissButton.widthAnchor.constraint(equalToConstant: view.frame.width - 40).isActive = true
        dissmissButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        
        inputImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -150).isActive = true
        inputImage.widthAnchor.constraint(equalToConstant: view.frame.width - 50).isActive = true

    }
    
    @objc func buttonToDissmiss(_ sender: BtnPleinLarge) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension OutputViewController {
    
    func predict(with cgImage: CGImage) {
        guard let request = request else { fatalError() }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
    
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        if let observations = request.results as? [VNCoreMLFeatureValueObservation],
            let segmentationmap = observations.first?.featureValue.multiArrayValue {
            let segmentationView = DrawingSegmentationView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth))
            segmentationView.backgroundColor = UIColor.clear
            segmentationView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(segmentationView)
            segmentationView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            segmentationView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -150).isActive = true
            segmentationView.widthAnchor.constraint(equalToConstant: view.frame.width - 50).isActive = true
            segmentationView.heightAnchor.constraint(equalToConstant: view.frame.width - 50).isActive = true
            segmentationView.segmentationmap = SegmentationResultMLMultiArray(mlMultiArray: segmentationmap)
            print(segmentationmap)
        }
    }
    
}

