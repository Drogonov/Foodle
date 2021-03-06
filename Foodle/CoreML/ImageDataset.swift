//
//  ImageDataset.swift
//  Foodle
//
//  Created by Anton Vlezko on 16.08.2021.
//

import UIKit

class Dataset: Injectable {
    let trainingDataset = ImageDataset(split: .train)
    let testingDataset = ImageDataset(split: .test)
}

/**
 A dataset is a list of all training or testing images and their true labels.
 */
class ImageDataset: Injectable {
    enum Split {
        case train
        case test
        
        var folderName: String {
            self == .train ? "train" : "test"
        }
    }
    
    let split: Split
    
    // When adding new images, we'll resize them so their smallest side
    // is this number of pixels.
    let smallestSide = 256
    
    private let baseURL: URL
    private var examples: [(String, String)] = []   // (filename, label)
    
    init(split: Split) {
        self.split = split
        baseURL = applicationDocumentsDirectory.appendingPathComponent(split.folderName)

    }
    
    func set(labels: Labels) {
        createDatasetFolder()
        createBuiltinLabelFolders(labels: labels)
        scanAllImageFiles(labels: labels)
    }
    
    /**
     Creates the folder for this dataset, if it doesn't exist yet.
     */
    private func createDatasetFolder() {
        print("Path for \(split): \(baseURL)")
        createDirectory(at: baseURL)
    }
    
    /**
     Creates a subfolder for a label, if it doesn't exist yet.
     */
    func createFolder(for label: String) {
        createDirectory(at: labelURL(for: label))
    }
    
    func deleteFolder(for label: String) {
        deleteDirectory(at: labelURL(for: label))
    }
    
    /**
     Creates the subfolders for the built-in labels, if they don't exist yet.
     */
    private func createBuiltinLabelFolders(labels: Labels) {
        for label in labels.builtinLabels {
            createFolder(for: label.labelEmoji)
        }
    }
    
    /**
     Reads the names of all the image files in the label's subfolder.
     */
    private func scanImageFiles(for label: String) {
        let url = labelURL(for: label)
        let filenames = fileURLs(at: url).map { $0.lastPathComponent }
        let labels = [String](repeating: label, count: filenames.count)
        examples.append(contentsOf: zip(filenames, labels))
    }
    
    /**
     Reads the names of all the image files in all the label subfolders.
     */
    private func scanAllImageFiles(labels: Labels) {
        examples = []
        for label in labels.labelsArray {
            scanImageFiles(for: label.labelEmoji)
        }
    }
    
    /**
     Returns a list of all the JPG and PNG images in the specified folder.
     */
    private func fileURLs(at url: URL) -> [URL] {
        contentsOfDirectory(at: url) { url in
            url.pathExtension == "jpg" || url.pathExtension == "png" || url.pathExtension == "jpeg"
        }
    }
    
    private func labelURL(for label: String) -> URL {
        baseURL.appendingPathComponent(label)
    }
    
    private func imageURL(for label: String, filename: String) -> URL {
        labelURL(for: label).appendingPathComponent(filename)
    }
    
    private func imageURL(for example: (String, String)) -> URL {
        imageURL(for: example.1, filename: example.0)
    }
    
    /** Returns the local file URL for the specified example's image. */
    func imageURL(at index: Int) -> URL {
        imageURL(for: examples[index])
    }
    
    /** Returns the label name for the specified example. */
    func label(at index: Int) -> String { examples[index].1 }
    
    /** The number of examples in this dataset. */
    var count: Int { examples.count }
    
    /**
     Returns the indices of the images having a certain label.
     */
    func images(withLabel label: String) -> [Int] {
        examples.indices.filter { self.label(at: $0) == label }
    }
}

// MARK: - UI stuff

extension ImageDataset {
    /**
     Returns the UIImage for the specified example. This is only for displaying
     inside the UI, not for training or evaluation.
     */
    func image(at index: Int) -> UIImage? {
        UIImage(contentsOfFile: imageURL(at: index).path)
    }
}

// MARK: - Mutating the dataset

extension ImageDataset {
    /**
     Reads the images from the Dataset folder inside the app bundle and copies
     them into the app's Documents directory.
     */
    func copyBuiltInImages(labels: Labels) {
        guard let baseURL = Bundle.main.url(forResource: split.folderName,
                                            withExtension: nil,
                                            subdirectory: "Dataset") else {
            fatalError("Error: built-in dataset not found")
        }
        
        for label in labels.builtinLabels {
            for fromURL in fileURLs(at: baseURL.appendingPathComponent(label.labelEmoji)) {
                let filename = fromURL.lastPathComponent
                let toURL = imageURL(for: label.labelEmoji, filename: filename)
                if copyIfNotExists(from: fromURL, to: toURL) {
                    examples.append((filename, label.labelEmoji))
                }
            }
        }
    }
    
    func addImage(_ image: UIImage, for label: String) {
        // Create a unique identifier to use as the filename.
        let filename = UUID().uuidString + ".jpg"
        let url = imageURL(for: label, filename: filename)
        
        // Already resize the image. We'll be training on small images anyway,
        // and it makes the UI faster to use as well.
        if let image = image.resized(smallestSide: smallestSide),
           let data = image.jpegData(compressionQuality: 0.5) {
            do {
                // Save as a JPEG into the app's Documents folder.
                try data.write(to: url, options: .atomic)
                
                // We always add new images to the end, but the next time you start the
                // app the order can be different, as we read the filenames in whatever
                // order the file system gives them to us.
                examples.append((filename, label))
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    func removeImage(at index: Int) {
        removeIfExists(at: imageURL(at: index))
        examples.remove(at: index)
    }
}

