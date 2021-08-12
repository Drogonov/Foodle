//
//  ImagesDataStore.swift
//  Foodle
//
//  Created by Anton on 12.08.2021.
//

import CoreML

class ImagesDataStore: NSObject {
    var images: [ImageForTrainingModel] = []
    let vegetableOrFruitName: String
    
    init(for vegetableOrFruitName: String, capacity: Int) {
        self.vegetableOrFruitName = vegetableOrFruitName
    }
}

extension ImagesDataStore {
    func prepareTrainingData() throws -> MLBatchProvider {
        var featureProviders: [MLFeatureProvider] = []
        let inputName = Constants.image
        let outputName = Constants.imageLabel
        
        for image in images {
            if let inputValue = image.featureValue {
                let outputValue = MLFeatureValue(string: vegetableOrFruitName)
                let dataPointFeature: [String: MLFeatureValue] = [inputName: inputValue, outputName: outputValue]
                
                if let provider = try? MLDictionaryFeatureProvider(dictionary: dataPointFeature) {
                    featureProviders.append(provider)
                }
            }
        }
        
        return MLArrayBatchProvider(array: featureProviders)
    }
}
