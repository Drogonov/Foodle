//
//  Vegetable.swift
//  Foodle
//
//  Created by Anton Vlezko on 10.08.2021.
//

import UIKit

struct Vegetable {
    let id = UUID()
    let name: String
    let image: UIImage?
    let emoji: String
    let modelStatus: VegetableModelStatus
}

struct VegetableViewModel: Equatable {
    struct Cell: VegetableCellViewModel, Equatable {
        var id: UUID
        var statusButtonColor: UIColor
        var vegetableImage: UIImage?
        var vegetableEmoji: String
        var vegetableName: String
    }
    
    var cells: [Cell]
    
    static func == (lhs: VegetableViewModel, rhs: VegetableViewModel) -> Bool {
        return lhs.cells == rhs.cells
    }
}

extension VegetableViewModel {
    init(vegetables: [Vegetable]) {
        self.cells = vegetables.map { vegetable -> Cell in
            let cell = Cell(
                id: vegetable.id,
                statusButtonColor: vegetable.modelStatus.color,
                vegetableImage: vegetable.image,
                vegetableEmoji: vegetable.emoji,
                vegetableName: vegetable.name
            )
            return cell
        }
    }
    
    init(labels: [Label]) {
        self.cells = labels.map { vegetable -> Cell in
            let cell = Cell(
                id: vegetable.id,
                statusButtonColor: .gray,
                vegetableImage: nil,
                vegetableEmoji: vegetable.labelEmoji,
                vegetableName: vegetable.labelName
            )
            return cell
        }
    }
}
