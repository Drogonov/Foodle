//
//  History.swift
//  Foodle
//
//  Created by Anton Vlezko on 16.08.2021.
//

import Foundation

/**
 History of training a neural network.
 
 This gets saved to history.json in the app's Documents folder.
 */
class History: Codable, Injectable {
    struct Event: Codable, Hashable {
        let epoch: Int
        let trainLoss: Double
        let validationLoss: Double
        let validationAccuracy: Double
    }
    
    private(set) var events: [Event] = []
    var count: Int { events.count }
    
    static func load() -> History {
        do {
            let data = try Data(contentsOf: historyURL)
            return try JSONDecoder().decode(History.self, from: data)
        } catch {
            return History()
        }
    }
    
    func addEvent(trainLoss: Double, validationLoss: Double, validationAccuracy: Double) {
        events.append(Event(epoch: events.count,
                            trainLoss: trainLoss,
                            validationLoss: validationLoss,
                            validationAccuracy: validationAccuracy))
        save()
    }
    
    func save() {
        do {
            let data = try JSONEncoder().encode(self)
            try data.write(to: historyURL)
        } catch {
            print("Error: \(error)")
        }
    }
    
    func delete() {
        events.removeAll()
        removeIfExists(at: historyURL)
    }
}

fileprivate var historyURL: URL {
    applicationDocumentsDirectory.appendingPathComponent("history.json")
}
