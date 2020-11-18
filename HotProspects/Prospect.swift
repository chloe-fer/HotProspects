//
//  Prospect.swift
//  HotProspects
//
//  Created by Chloe Fermanis on 28/9/20.
//  Copyright © 2020 Chloe Fermanis. All rights reserved.
//

import SwiftUI

class Prospect: Identifiable, Codable {
    
    var id = UUID()
    var name = "Anonymouse"
    var emailAddress = ""
    fileprivate(set) var isContacted = false
    var dateAdded = Date()
    
//    static func < (lhs: Prospect, rhs: Prospect) -> Bool {
//        lhs.name < rhs.name
//    }
//
//    static func == (lhs: Prospect, rhs: Prospect) -> Bool {
//        lhs.name == rhs.name
//    }
    
}

class Prospects: ObservableObject {
    
    @Published private(set) var people: [Prospect]
    static let saveKey = "SavedData"
    
    init() {
//        if let data = UserDefaults.standard.data(forKey: Prospects.saveKey) {
//            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
//                self.people = decoded
//                return
//            }
//        }
//        self.people = []
        
        let filename = FileManager.default.getDocumentDirectory().appendingPathComponent("SavedPeople")
        do {
            let data = try Data(contentsOf: filename)
            self.people = try JSONDecoder().decode([Prospect].self, from: data)
            return
        } catch {
            self.people = []
            print("Unable to load saved data.")
        }
    }
    
    private func save() {
        
        // if let encoded = try? JSONEncoder().encode(people) {
            // UserDefaults.standard.set(encoded, forKey: Self.saveKey)
        do {
            let filename = FileManager.default.getDocumentDirectory().appendingPathComponent("SavedPeople")
            let data = try JSONEncoder().encode(people)
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Unable to save data")
        }
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
    
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
}
