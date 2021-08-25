//
//  ImagesByLabel.swift
//  Foodle
//
//  Created by Anton Vlezko on 16.08.2021.
//

import UIKit

/**
 Organizes the images from an ImageDataset grouped by their labels.
 
 This is used by the "Training Data" and "Test Data" screens, as well as the
 "Train k-Nearest Neighbors" screen.
 */

class ImagesByLabel: ObservableObject {
    @Inject var labels: Labels
    let dataset: ImageDataset
    private var groups: [String: [Int]] = [:]
    @Published var labelsArray: [LabelSection] = []
    
    init(dataset: ImageDataset) {
        self.dataset = dataset
        self.labelsArray = set()
    }
    
    func getData() -> [LabelSection] {
        return labelsArray
    }
    
    func addImage(_ image: UIImage, for label: String) {
        dataset.addImage(image, for: label)
        
        // The new image is always added at the end, so we can simply append
        // the new index to the group for this label.
        groups[label]!.append(dataset.count - 1)
        labelsArray = set()
    }
    
    func removeImage(for label: String, at index: Int) {
        dataset.removeImage(at: flatIndex(for: label, at: index))
        
        // All the image indices following the deleted image are now off by one,
        // so recompute all the groups.
        labelsArray = set()
    }
    
    func numberOfImages(for label: String) -> Int {
        groups[label]!.count
    }
    
    private func updateGroups() {
        groups = [:]
        for label in labels.labelsArray {
            groups[label.labelEmoji] = dataset.images(withLabel: label.labelEmoji)
        }
        debugPrint(groups)
    }
    
    private func set() -> [LabelSection] {
        updateGroups()
        return labels.labelsArray.map { label -> LabelSection in
            let numberOfImages = numberOfImages(for: label.labelEmoji)
            var images: [UIImage] = []

            for i in 0..<numberOfImages {
                guard let image = image(for: label.labelEmoji, at: i) else { break }
                images.append(image)
            }

            let section = LabelSection(
                sectionLabel: label.labelEmoji,
                items: images
            )

            return section
        }
    }
    
    private func image(for label: String, at index: Int) -> UIImage? {
        dataset.image(at: flatIndex(for: label, at: index))
    }
        
    private func flatIndex(for label: String, at index: Int) -> Int {
        groups[label]![index]
    }
}
