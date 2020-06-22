//
//  ViewController.swift
//  Intelligent Image
//
//  Created by Yusuf ÇAĞLAR on 29/10/2018.
//  Copyright © 2018 Yusuf ÇAĞLAR. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    var chosenImage = CIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func changeClicked(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        if let ciImage = CIImage(image: imageView.image!) {
            self.chosenImage = ciImage
        }
        
        recognizeImage(image: chosenImage)
    }
    
    func recognizeImage(image: CIImage) {
        
        resultLabel.text = "Finding ..."
        
        if let model = try? VNCoreMLModel(for: GoogLeNetPlaces().model) {
            
            let request = VNCoreMLRequest(model: model) { (vnrequest, error) in
                
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    
                    let topResult = results.first
                    
                    DispatchQueue.main.async {
                        
                        
                        let conf = (topResult?.confidence)! * 100
                        
                        let rounded = Int(conf * 100) / 100
                        
                        self.resultLabel.text = "\(rounded)% it's \(String(describing: topResult!.identifier))"
                    }
                }
            }
            
            let handler = VNImageRequestHandler(ciImage: image)
            
            DispatchQueue.global(qos: .userInteractive).async {
                
                do {
                    try handler.perform([request])
                } catch {
                    print("error")
                }
            }
            
        }
    }
}

