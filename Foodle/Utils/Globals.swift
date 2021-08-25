//
//  Globals.swift
//  Foodle
//
//  Created by Anton Vlezko on 16.08.2021.
//

import Foundation

// For the sake of convenience, the datasets are global objects.

let trainingDataset = ImageDataset(split: .train)
let testingDataset = ImageDataset(split: .test)
//let labels = Labels()
//let settings = Settings()
//let history = History.load()

protocol Injectable {}

@propertyWrapper
struct Inject<T: Injectable> {
    let wrappedValue: T
    
    init() {
        wrappedValue = Resolver.shared.resolve()
    }
}

class Resolver {
    
    private var storage = [String: Injectable]()
    
    static let shared = Resolver()
    private init() {
        debugPrint("Resolver inited")
    }
    
    func add<T: Injectable>(_ injectable: T) {
        let key = String(reflecting: injectable)
        storage[key] = injectable
    }

    func resolve<T: Injectable>() -> T {
        let key = String(reflecting: T.self)
        
        guard let injectable = storage[key] as? T else {
            fatalError("\(key) has not been added as an injectable object.")
        }
        
        return injectable
    }

}

class DependencyManager {
    private let labels: Labels
    private let settings: Settings
    private let history: History
    
    init() {
        self.labels = Labels()
        self.settings = Settings()
        self.history = History.load()
        addDependencies()
    }
    
    private func addDependencies() {
        let resolver = Resolver.shared
        resolver.add(labels)
        resolver.add(settings)
        resolver.add(history)
    }
}
