//
//  Labels.swift
//  Foodle
//
//  Created by Anton Vlezko on 16.08.2021.
//

import Foundation

/**
 Manages the class labels used by the k-NN and neural network models.
 */

struct Label: Hashable, Codable {
    var id = UUID()
    var labelEmoji: String
    var labelName: String
}

class Labels {
    let maxLabels = 10
    
    // The dataset always has these three labels but the user can add their own.
    //    let builtinLabelNames = [ "🍅", "🍎", "🥒" ]
    let builtinLabels = [Label(labelEmoji: "🍅",
                               labelName: "Tomato"),
                         Label(labelEmoji: "🍎",
                               labelName: "Apple"),
                         Label(labelEmoji: "🥒",
                               labelName: "Cucumber")]
    
    // The names of the labels as chosen by the user (plus the built-in ones).
    //    var labelNames: [String] = []
    var labelsArray: [Label] = []
    
    // Which output neuron corresponds to which user-chosen label name.
    var labelIndices: [Label: Int] {
        Dictionary(uniqueKeysWithValues: zip(labelsArray, labelsArray.indices))
    }
    
    // The names of the labels for the neural network in the mlmodel file: user0,
    // user1, user2, and so on. Core ML's predictions will use these labels, but
    // we don't want to show these to the user.
    //
    // Note: It would be best if we grabbed these class names from the mlmodel,
    // but there is no API that lets us do this right now (apart from making an
    // actual prediction). Although it is possible to add the class names as
    // metadata in the mlmodel and then we can read them from modelDescription.
    //
    // Note: These internal label names are only needed for the neural network.
    // The app lets users add new gestures, but a neural net always has a fixed
    // number of outputs. That's why we've added 7 placeholder labels in addition
    // to the 3 built-in ones.
    //
    // k-NN does not have this restriction, and the label names inside the k-NN's
    // mlmodel are always the ones chosen by the user.
    lazy var internalLabels: [Label] = {
        builtinLabels + (0..<7).map { index -> Label in
            let lb = Label(labelEmoji: "🐊",
                           labelName: "user\(index)")
            return lb
        }
    }()
    
    // Which output neuron corresponds to which label name in the mlmodel file.
    lazy var internalLabelIndices: [Label: Int] = {
        Dictionary(uniqueKeysWithValues: zip(internalLabels, internalLabels.indices))
    }()
    
    init() {
        readLabelNames()
    }
    
    private var labelNamesURL: URL {
        applicationDocumentsDirectory.appendingPathComponent("labels.json")
    }
    
    /**
     The first three labels are always the same (🍅, 🍎, 🥒) but we also allow
     users to add their own. The new labels are written to labels.json because it
     is important that we read them in the same order every time.
     */
    private func readLabelNames() {
        do {
            let data = try Data(contentsOf: labelNamesURL)
            labelsArray = try JSONDecoder().decode(Array<Label>.self, from: data)
        } catch {
            labelsArray = builtinLabels
        }
    }
    
    private func saveLabelNames() {
        do {
            let data = try JSONEncoder().encode(labelsArray)
            try data.write(to: labelNamesURL)
        } catch {
            print("Error: \(error)")
        }
    }
    
    /**
     Adds a new label that is chosen by the user.
     
     We always add the new label name to the end of the list, because the neural
     network may already have been trained on the other labels. If we change the
     order, the predictions will no longer make sense!
     */
    func addLabel(_ label: Label) {
        if !labelsArray.contains(label) {
            labelsArray.append(label)
            saveLabelNames()
        }
    }
    
    func deleteLabel(_ label: Label) {
        if let index = labelsArray.firstIndex(where: {$0.labelEmoji == label.labelEmoji}) {
            debugPrint("deleted")
            labelsArray.remove(at: index)
            saveLabelNames()
        }
    }
    
    /**
     Converts an internal label, such as "user0", into a user-chosen label.
     This is useful for converting predictions, which use the internal name,
     into text for display. (Used only for the neural network; for k-NN there
     is no difference between internal labels and user-chosen labels.)
     */
    func userLabel(for internalLabel: String) -> String {
        debugPrint("internalLabel \(internalLabel)")
        if let index = internalLabels.firstIndex(where: { $0.labelName == internalLabel }) {
            let label = internalLabels[index]
            if let idx = internalLabelIndices[label], idx < labelsArray.count {
                return labelsArray[idx].labelEmoji
            }
        }
        return internalLabel
    }
    
    /**
     Looks up the internal label, such as "user0", that corresponds to a given
     user-chosen label. This is needed to match a prediction, which always uses
     the internal label, to the label used by the ImageDataset. (Used only for
     the neural network; for k-NN there is no difference between internal labels
     and user-chosen labels.)
     */
    func internalLabel(for userLabel: String) -> String {
        if let index = labelsArray.firstIndex(where: {$0.labelEmoji == userLabel}) {
            let label = internalLabels[index]
            if let idx = internalLabelIndices[label], idx < labelsArray.count {
                debugPrint("return userLabel labelName \(internalLabels[idx].labelName)")
                return internalLabels[idx].labelEmoji
            } else {
                debugPrint("return userLabel userLabel \(userLabel)")
                return userLabel
            }
        } else {
            debugPrint("userLabel \(userLabel)")
            return userLabel
        }
    }
}

