//
//  ImageForTrainingModel.swift
//  Foodle
//
//  Created by Anton on 12.08.2021.
//

import CoreML
import UIKit

struct ImageForTrainingModel {
    let image: UIImage
    
    var featureValue: MLFeatureValue? {
        guard let cgImage = image.cgImage,
              let imageConstraint = UpdatableModel.imageConstraint else {
            debugPrint("Couldn't create CGImage from UIImage")
            return nil
        }
        let imageFeatureValue = try? MLFeatureValue(cgImage: cgImage, constraint: imageConstraint)
        return imageFeatureValue
    }
}
