//
//  Vegetable.swift
//  Foodle
//
//  Created by Anton Vlezko on 10.08.2021.
//

import UIKit

enum VegetableModelStatus {
    case empty
    case partlyFilled
    case full
    
    var color: UIColor {
        switch self {
        case .empty:
            return .red
        case .partlyFilled:
            return .yellow
        case .full:
            return .green
        }
    }
}

struct Vegetable {
    let id = UUID()
    let name: String
    let image: UIImage?
    let modelStatus: VegetableModelStatus
}

struct VegetableViewModel {
    struct Cell: VegetableCellViewModel {
        var id: UUID
        var statusButtonColor: UIColor
        var vegetableImage: UIImage?
        var vegetableName: String
    }
    
    var cells: [Cell]
}

extension VegetableViewModel {
    init(vegetables: [Vegetable]) {
        self.cells = vegetables.map { vegetable -> Cell in
            let cell = Cell(
                id: vegetable.id,
                statusButtonColor: vegetable.modelStatus.color,
                vegetableImage: vegetable.image,
                vegetableName: vegetable.name
            )
            return cell
        }
    }
}
