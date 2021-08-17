//
//  SettingsSection.swift
//  Foodle
//
//  Created by Anton Vlezko on 17.08.2021.
//

import SwiftUI

struct SettingsMenuSection: Identifiable {
    let id = UUID()
    let sectionName: String
    let items: [SettingsMenuItem]
}

struct SettingsMenuItem: Identifiable {
    let id = UUID()
    let itemName: String
    var itemColor: Color = Color(.label)
    var settingsType: SettingsType
}
