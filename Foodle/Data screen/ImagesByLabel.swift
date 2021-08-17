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

struct LabelSection: Identifiable {
    let id = UUID()
    var sectionLabel: String
    var items: [UIImage?] = []
}


class ImagesByLabel {
    let dataset: ImageDataset
    private var groups: [String: [Int]] = [:]
    
//    private var labels = Labels()
    private var labelsArray: [LabelSection] = []
    
    init(dataset: ImageDataset) {
        self.dataset = dataset
        set()
    }
    
    func getData() -> [LabelSection] {
        return labelsArray
    }
    
    private func set() {
        updateGroups()
        labelsArray = labels.labelNames.map { label -> LabelSection in
            let numberOfImages = numberOfImages(for: label)
            var images: [UIImage] = []

            for i in 0..<numberOfImages {
                guard let image = image(for: label, at: i) else { break }
                images.append(image)
            }

            let section = LabelSection(
                sectionLabel: label,
                items: images
            )

            return section
        }
    }
    
    func addImage(_ image: UIImage, for label: String) {
        dataset.addImage(image, for: label)
        
        // The new image is always added at the end, so we can simply append
        // the new index to the group for this label.
        groups[label]!.append(dataset.count - 1)
        set()
    }
    
    func removeImage(for label: String, at index: Int) {
        dataset.removeImage(at: flatIndex(for: label, at: index))
        
        // All the image indices following the deleted image are now off by one,
        // so recompute all the groups.
        set()
    }
    
    private func updateGroups() {
        groups = [:]
        for label in labels.labelNames {
            groups[label] = dataset.images(withLabel: label)
        }
    }
        
//    var numberOfLabels: Int { labels.labelNames.count }
    
//    func labelName(of group: Int) -> String { labels.labelNames[group] }
    
    func numberOfImages(for label: String) -> Int {
        groups[label]!.count
    }
    
    private func image(for label: String, at index: Int) -> UIImage? {
        dataset.image(at: flatIndex(for: label, at: index))
    }
        
    private func flatIndex(for label: String, at index: Int) -> Int {
        groups[label]![index]
    }
}