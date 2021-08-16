//
//  Globals.swift
//  Foodle
//
//  Created by Anton Vlezko on 16.08.2021.
//

import Foundation

// For the sake of convenience, the datasets are global objects.

let labels = Labels()
let trainingDataset = ImageDataset(split: .train)
let testingDataset = ImageDataset(split: .test)
let settings = Settings()
let history = History.load()
