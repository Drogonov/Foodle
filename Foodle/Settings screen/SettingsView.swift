//
//  SettingsView.swift
//  Foodle
//
//  Created by Anton Vlezko on 16.08.2021.
//

import SwiftUI

struct SettingsView: View {
    @State private var isBackgroundTrainingEnabled: Bool = false
    var menu: [SettingsMenuSection]
    var buttonTapped: (SettingsButtonType) -> Void
    var routerTapped: (Router) -> Void
    var backgroundTrainingEnabled: (Bool) -> Void
    
    public var body: some View {
        List {
            ForEach(menu) { section in
                Section(header: Text(section.sectionName)) {
                    ForEach(section.items) { item in
                        VStack {
                            switch item.settingsType {
                            case .button(type: let type):
                                Button(action: {
                                    buttonTapped(type)
                                },
                                label: {
                                    Text(item.itemName)
                                        .foregroundColor(item.itemColor)
                                })
                            case .router(router: let router):
                                Button(action: {
                                    routerTapped(router)
                                },
                                label: {
                                    Text(item.itemName)
                                        .foregroundColor(item.itemColor)
                                })
                            case .toogle:
                                Toggle(item.itemName, isOn: $isBackgroundTrainingEnabled)
                                    .foregroundColor(item.itemColor)
                                    .onChange(of: isBackgroundTrainingEnabled,
                                              perform: { value in
                                                backgroundTrainingEnabled(value)
                                              }
                                    )
                            }
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
    }
}
