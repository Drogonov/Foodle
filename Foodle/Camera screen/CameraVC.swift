//
//  CameraVC.swift
//  Foodle
//
//  Created by Anton Vlezko on 10.08.2021.
//

import SwiftUI
import UIKit
import CoreML
import Vision

class CameraVC: UIViewController {
    // MARK: - Properties
    var imageView = UIImageView()
    var textView = UITextView()
    let barTitle: String = "Camera"
    
    var model: MLModel!
    var predictor: Predictor!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        textView.text = "Use the camera to take a photo."
        predictor = Predictor(model: model)
    }
    
    // MARK: - Selectors
    
    @objc func cameraTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func predict(image: UIImage) {
        let constraint = imageConstraint(model: model)

        let imageOptions: [MLFeatureValue.ImageOption: Any] = [
            .cropAndScale: VNImageCropAndScaleOption.scaleFill.rawValue
        ]
        
//         In the "Evaluate" screen we load the image from the dataset but here
//         we use a UIImage / CGImage object.
        if let cgImage = image.cgImage,
           let featureValue = try? MLFeatureValue(cgImage: cgImage,
                                                  orientation: .up,
                                                  constraint: constraint,
                                                  options: imageOptions),
           let prediction = predictor.predict(image: featureValue) {
            textView.text = makeDisplayString(prediction)
        }
    }
    
    private func makeDisplayString(_ prediction: Prediction) -> String {
      var s = "Prediction: \(prediction.label)\n"
      s += String(format: "Probability: %.2f%%\n\n", prediction.confidence * 100)
      s += "Results for all classes:\n"
      s += prediction.sortedProbabilities
        .map { String(format: "%@ %f", labels.userLabel(for: $0.0), $0.1) }
                     .joined(separator: "\n")
      return s
    }
    
    // MARK: - Helper Functions
    
    func configureUI() {
        configureNavigationBar()
        configureImageView()
        configureTextView()
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = UIColor.systemYellow
        navigationItem.title = barTitle
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage().systemImage(withSystemName: "camera"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(cameraTapped))
        
    }
    
    func configureImageView() {
        view.addSubview(imageView)
        imageView.setDimensions(height: 227,
                                width: 227)
        imageView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         paddingTop: 16)
        imageView.centerX(inView: view)
    }
    
    func configureTextView() {
        textView.font = UIFont.boldSystemFont(ofSize: 18)
        textView.textAlignment = .center
        textView.showsVerticalScrollIndicator = false

        view.addSubview(textView)
        textView.anchor(
            top: imageView.bottomAnchor,
            leading: view.safeAreaLayoutGuide.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            trailing: view.safeAreaLayoutGuide.rightAnchor,
            paddingTop: 16,
            paddingLeft: 16,
            paddingRight: 16
        )
    }
    
    /**
      Because the images may not be exactly 227x227 pixels, we use the new
      MLFeatureValue(imageAt:) API to crop / scale the image.

      We need to tell the MLFeatureValue how large the image should be and
      what pixel format the model expects. You can hardcode these numbers,
      but it's easiest to grab the MLImageConstraint from the model input.

      We need to do this in several different places, which is why we'll use
      this helper function.
     */
    func imageConstraint(model: MLModel) -> MLImageConstraint {
      return model.modelDescription.inputDescriptionsByName["image"]!.imageConstraint!
    }
    
}

extension CameraVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        imageView.image = image
        
        predict(image: image)
    }
}
