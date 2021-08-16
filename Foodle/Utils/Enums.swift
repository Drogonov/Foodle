//
//  Enums.swift
//  Foodle
//
//  Created by Anton Vlezko on 11.08.2021.
//

import UIKit

enum NotificationConfiguration {
    case textField
    case defaultAction
    case rejectAction
    
    init() {
        self = .defaultAction
    }
}

enum VegetableModelStatus {
    case empty
    case partlyFilled
    case full
    
    var color: UIColor {
        switch self {
        case .empty:
            return .systemRed
        case .partlyFilled:
            return .systemYellow
        case .full:
            return .systemGreen
        }
    }
}

enum Router {
    case trainingData
    case testingData
    case train
    case evaluate
}

enum SettingsButtonType {
    case loadDataSet
    case resetToEmpty
    case resetToTuri
}

enum SettingsType {
    case button(type: SettingsButtonType)
    case router(router: Router)
    case toogle
}
