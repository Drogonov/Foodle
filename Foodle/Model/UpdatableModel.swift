//
//  UpdatedModel.swift
//  Foodle
//
//  Created by Anton on 12.08.2021.
//

import CoreML

struct UpdatableModel {
    private static var updatedVegetablesAndFruitsClassifierr: VegetablesAndFruitsClassifier?
    private static let appDirectory = FileManager.default.urls(for: .applicationSupportDirectory,
                                                               in: .userDomainMask).first!
    private static let defaultModelUrl = VegetablesAndFruitsClassifier.urlOfModelInThisBundle
    private static var updatedModelUrl = appDirectory.appendingPathComponent(Constants.personalized)
    private static var tempUpdatedModelUrl = appDirectory.appendingPathComponent(Constants.personalizedTemp)
    private static let fileManager = FileManager.default
    private static let updateModelParentUrl = updatedModelUrl.deletingLastPathComponent()
    
    private init() {}
    
    static var imageConstraint: MLImageConstraint? {
        return updatedVegetablesAndFruitsClassifierr?.imageConstraint
    }
    
    private static var fileExist: Bool {
        fileManager.fileExists(atPath: updatedModelUrl.path)
    }
    
    private static var tempDirectory: URL {
        updateModelParentUrl.appendingPathComponent(defaultModelUrl.lastPathComponent)
    }
}

extension UpdatableModel {
    static func predictLabelFor(_ value: MLFeatureValue) -> String? {
        loadModel()
        return updatedVegetablesAndFruitsClassifierr?.predictLabelFor(value)
    }
    
    static func updateWith(trainingData: MLBatchProvider, completionHandler: @escaping () -> Void) {
    loadModel()
        VegetablesAndFruitsClassifier.updateModel(at: updatedModelUrl,
                                                  with: trainingData) { context in
            saveUpdatedModel(context)
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }
}

private extension UpdatableModel {
    static func loadModel() {
        if !fileExist {
            createTempDirectory()
            copyModelToTempDirectory()
            moveModelToUpdatedDirectory()
        }
        
        guard let model = try? VegetablesAndFruitsClassifier(contentsOf: updatedModelUrl) else { return }
        
        updatedVegetablesAndFruitsClassifierr = model
    }
    
    static func saveUpdatedModel(_ updateContext: MLUpdateContext) {
        let updatedModel = updateContext.model
        createTempDirectory()
        writeToTempDirectory(updatedModel)
        replaceModelUrl()
    }
    
    private static func replaceModelUrl() {
        do {
            _ = try fileManager.replaceItemAt(updatedModelUrl, withItemAt: tempUpdatedModelUrl)
        } catch {
            debugPrint("don't replace the model folder’s content: \(error.localizedDescription)")
            return
        }
    }
    
    private static func writeToTempDirectory(_ updatedModel: MLModel & MLWritable) {
        do {
            try updatedModel.write(to: tempUpdatedModelUrl)
        } catch {
            debugPrint("don't write to temp directory: \(tempUpdatedModelUrl)")
            return
        }
    }
    
    private static func createTempDirectory() {
        do {
            try fileManager.createDirectory(at: updateModelParentUrl,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
        } catch {
            debugPrint("don't create a directory: \(updateModelParentUrl)")
            return
        }
    }
    
    private static func copyModelToTempDirectory() {
        do {
            try fileManager.copyItem(at: defaultModelUrl,
                                     to: tempDirectory)
        } catch {
            debugPrint("don't copy model to temp directory: \(tempDirectory)")
            return
        }
    }
    
    private static func moveModelToUpdatedDirectory() {
        do {
            try fileManager.moveItem(at: tempDirectory,
                                     to: updatedModelUrl)
        } catch {
            debugPrint("don't move model to updated directory: \(error.localizedDescription)")
            return
        }
    }
}
