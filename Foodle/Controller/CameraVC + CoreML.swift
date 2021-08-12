//
//  CameraVC + CoreML.swift
//  Foodle
//
//  Created by Anton on 11.08.2021.
//

import UIKit
import CoreML
import Vision

extension CameraVC {
    func addImageToImageDataStore() {
        do {
            if let trainingData = try imagesDataStore?.prepareTrainingData() {
                DispatchQueue.global(qos: .userInitiated).async {
                    UpdatableModel.updateWith(trainingData: trainingData) {
                        DispatchQueue.main.async {
                            // TODO например закрыть imagePicker
                        }
                    }
                }
            }
        } catch {
            print("Error updating model", error)
        }
    }
    
    func classificationProcess(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            if let classifications = request.results as? [VNClassificationObservation] {
                let topConfidence = classifications.first?.confidence
                self.vegetableName = topConfidence?.description
            }
        }
    }
    
    func recognize(_ image: UIImage) {
        guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)) else { return }
        
        guard let ciImage = CIImage(image: image) else {
            fatalError("Unable to create \(CIImage.self) from \(image).")
        }
        
        performRecognitionRequest(ciImage, orientation)
    }
    
    fileprivate func performRecognitionRequest(_ ciImage: CIImage, _ orientation: CGImagePropertyOrientation) {
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.recognitionRequest])
            } catch {
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
}
