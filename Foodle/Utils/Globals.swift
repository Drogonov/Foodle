//
//  Globals.swift
//  Foodle
//
//  Created by Anton Vlezko on 16.08.2021.
//

import Foundation

// For the sake of convenience, the datasets are global objects.

struct Globals {
    static let shared = Globals()

    let trainingDataset = ImageDataset(split: .train)
    let testingDataset = ImageDataset(split: .test)
}

let labels = Labels()
let settings = Settings()
let history = History.load()




