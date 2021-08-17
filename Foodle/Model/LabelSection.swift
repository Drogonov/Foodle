//
//  LabelSection.swift
//  Foodle
//
//  Created by Anton Vlezko on 17.08.2021.
//

import UIKit

struct LabelSection: Identifiable {
    let id = UUID()
    var sectionLabel: String
    var items: [UIImage?] = []
}
