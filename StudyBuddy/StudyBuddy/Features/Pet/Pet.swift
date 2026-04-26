import Foundation
import SwiftData

@Model
final class Pet {
    var species: String
    var name: String
    var hunger: Int
    var mood: Int
    var lastFedAt: Date

    init(species: String, name: String, hunger: Int, mood: Int, lastFedAt: Date) {
        self.species = species
        self.name = name
        self.hunger = hunger
        self.mood = mood
        self.lastFedAt = lastFedAt
    }

    static var `default`: Pet {
        Pet(species: "Capybara", name: "Mochi", hunger: 40, mood: 80, lastFedAt: .now)
    }

    static let speciesOptions: [String] = ["Capybara", "Mouse", "Dinosaur", "Dog", "Cat"]
}
