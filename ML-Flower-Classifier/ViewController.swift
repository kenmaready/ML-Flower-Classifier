//
//  ViewController.swift
//  ML-Flower-Classifier
//
//  Created by Ken Maready on 8/3/22.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var mainImageView: UIImageView!
    let imagePicker = UIImagePickerController()
    var wikiRequest = WikiRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerSetup()
        wikiRequest.delegate = self
    }
}

// MARK: - UIImaagePickerControllerDelegate

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerSetup() {
        imagePicker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            print("Camera is not available on this device/simulator.")
            imagePicker.sourceType = .photoLibrary
        }
        imagePicker.allowsEditing = false
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            mainImageView.image = image
            
            guard let ciImage = CIImage(image: image) else {
                fatalError("Error occurred in converting selected image to CIImage.")
            }
            
            detect(ciImage)
    
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectImageButtonPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: - WikiRequestDelagate

extension ViewController: WikiRequestDelegate {
    func detect(_ image: CIImage) {
        print("detect() function called....")
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError("Error occured during instantiation of MLModel")
        }
        
        print("request being made...")
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Error occurred during processing of model or retrieval of results from model")
            }
            
            let classification = request.results?.first as? VNClassificationObservation
            
            self.navigationItem.title = classification?.identifier.capitalized
            if let flowername = classification?.identifier {
                self.wikiRequest.fetchInfo(flowername)
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print("Error occurred during request of analyses from MLModel")
        }
    }

    func didUpdateInfo(_: WikiInfo) {
            
    }
    
    func didFailWithError(_: Error) {
        
    }
    
    
}
