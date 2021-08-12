//
//  Classifier + Ext.swift
//  Foodle
//
//  Created by Anton on 12.08.2021.
//

import CoreML

extension VegetablesAndFruitsClassifier {
    var imageConstraint: MLImageConstraint {
        return model.modelDescription
            .inputDescriptionsByName[Constants.image]!
            .imageConstraint!
    }
    
    func predictLabelFor(_ value: MLFeatureValue) -> String? {
        guard let pixelBuffer = value.imageBufferValue,
              let prediction = try? prediction(image: pixelBuffer).classLabel else {
            return nil
        }
        if prediction == Constants.unnown {
            return nil
        }
        return prediction
    }
    
    static func updateModel(at url: URL,
                            with trainingData: MLBatchProvider,
                            completionHandler: @escaping (MLUpdateContext) -> Void) {
        do {
            let updateTask = try MLUpdateTask(forModelAt: url,
                                              trainingData: trainingData,
                                              configuration: nil,
                                              completionHandler: completionHandler)
            updateTask.resume()
        } catch {
            debugPrint("Couldn't create an MLUpdateTask")
        }
    }
}
