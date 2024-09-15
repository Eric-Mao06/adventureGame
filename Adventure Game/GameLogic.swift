//
//  YourGame.swift
//  Adventure Game
//
//  Created by Eric Mao on 9/14/24.
//

import SwiftUI

enum Direction: String {
    case north, south, east, west
}

enum Item: String {
    case magicCompass = "Magic Compass"
}

protocol Interactable {
    func interact(context: AdventureGameContext, game: GameLogic) -> GameLogic
}

protocol AdventureGameContext {
    func write(_ string: String)
    func endGame()
}

struct Location {
    let name: String
    let description: String
    var exits: [Direction: String]
    var item: Item?
    var interactable: Interactable?
}

struct AncientOak: Interactable {
    func interact(context: AdventureGameContext, game: GameLogic) -> GameLogic {
        let modifiedGame = game
        if modifiedGame.inventory.contains(.magicCompass) {
            context.write("The Magic Compass glows. The oak tree opens, revealing a path out. You escape!")
            modifiedGame.gameIsRunning = false
            context.endGame()
        } else {
            context.write("The oak tree remains silent. Perhaps you need something special to proceed.")
        }
        return modifiedGame
    }
}

class GameLogic: ObservableObject {
    var currentLocation: Location
    var inventory: [Item]
    var gameMap: [String: Location]
    var gameIsRunning: Bool

    init() {
        // Define locations
        let ancientOak = Location(
            name: "Ancient Oak",
            description: "A massive oak tree with a door carved into its trunk.",
            exits: [.south: "Enchanted River"],
            item: nil,
            interactable: AncientOak()
        )

        let enchantedRiver = Location(
            name: "Enchanted River",
            description: "A river with water that glows faintly. A rickety bridge crosses it.",
            exits: [.south: "Abandoned Hut", .north: "Ancient Oak"],
            item: nil,
            interactable: nil
        )

        let abandonedHut = Location(
            name: "Abandoned Hut",
            description: "An old hut that seems to have been left in a hurry.",
            exits: [.east: "Whispering Woods", .north: "Enchanted River"],
            item: nil,
            interactable: nil
        )

        let crystalCave = Location(
            name: "Crystal Cave",
            description: "A cave glittering with crystals. It's both beautiful and eerie.",
            exits: [.west: "Whispering Woods"],
            item: .magicCompass,
            interactable: nil
        )

        let whisperingWoods = Location(
            name: "Whispering Woods",
            description: "Trees here seem to whisper secrets. The path splits.",
            exits: [.south: "Mysterious Clearing", .east: "Crystal Cave", .west: "Abandoned Hut"],
            item: nil,
            interactable: nil
        )

        let mysteriousClearing = Location(
            name: "Mysterious Clearing",
            description: "A circular clearing surrounded by ancient trees. The ground is covered in strange symbols.",
            exits: [.north: "Whispering Woods"],
            item: nil,
            interactable: nil
        )

        // Build game map
        self.gameMap = [
            "Mysterious Clearing": mysteriousClearing,
            "Whispering Woods": whisperingWoods,
            "Crystal Cave": crystalCave,
            "Abandoned Hut": abandonedHut,
            "Enchanted River": enchantedRiver,
            "Ancient Oak": ancientOak
        ]

        // Set starting location
        self.currentLocation = mysteriousClearing

        // Initialize inventory
        self.inventory = []

        // Game is running
        self.gameIsRunning = true
    }

    //Start Function
    func start(context: AdventureGameContext) {
        context.write("You awaken in a mysterious forest with no memory of how you got there.")
        describeCurrentLocation(context: context)
    }

    //User Input
    func handle(input: String, context: AdventureGameContext) {
        guard gameIsRunning else {
            context.write("The game is over. Please reset to play again.")
            return
        }

        let lowercasedInput = input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        if lowercasedInput == "help" {
            displayHelp(context: context)
        } else if ["north", "south", "east", "west"].contains(lowercasedInput) {
            if let direction = Direction(rawValue: lowercasedInput) {
                move(direction: direction, context: context)
            } else {
                context.write("Invalid direction.")
            }
        } else if lowercasedInput.hasPrefix("take ") {
            let itemName = String(lowercasedInput.dropFirst(5))
            takeItem(named: itemName, context: context)
        } else if lowercasedInput.hasPrefix("use ") {
            let itemName = String(lowercasedInput.dropFirst(4))
            useItem(named: itemName, context: context)
        } else if lowercasedInput == "look" {
            describeCurrentLocation(context: context)
        } else if lowercasedInput == "inventory" {
            displayInventory(context: context)
        } else {
            context.write("I don't understand that command.")
        }
    }

    func move(direction: Direction, context: AdventureGameContext) {
        if let nextLocationName = currentLocation.exits[direction],
           let nextLocation = gameMap[nextLocationName] {
            currentLocation = nextLocation
            context.write("You move \(direction.rawValue).")
            describeCurrentLocation(context: context)
            checkForSpecialConditions(context: context)
        } else {
            context.write("You can't go that way.")
        }    }

    func displayHelp(context: AdventureGameContext) {
        context.write("""
        Available commands:
        - Movement: north, south, east, west
        - Actions: look, take [item], use [item], inventory
        - help: Displays this help message
        """)
    }

    func describeCurrentLocation(context: AdventureGameContext) {
        context.write("\nYou are at the \(currentLocation.name).")
        context.write(currentLocation.description)
        if !currentLocation.exits.isEmpty {
            let exitsList = currentLocation.exits.keys.map { $0.rawValue }.joined(separator: ", ")
            context.write("Exits are: \(exitsList).")
        }
        if let item = currentLocation.item {
            context.write("You see a \(item.rawValue) here.")
        }    }

    func takeItem(named itemName: String, context: AdventureGameContext) {
        if let item = currentLocation.item, item.rawValue.lowercased() == itemName {
            inventory.append(item)
            currentLocation.item = nil
            context.write("You pick up the \(item.rawValue).")
        } else {
            context.write("There is no \(itemName) here.")
        }
    }

    func displayInventory(context: AdventureGameContext) {
        if inventory.isEmpty {
            context.write("Your inventory is empty.")
        } else {
            let itemList = inventory.map { $0.rawValue }.joined(separator: ", ")
            context.write("You are carrying: \(itemList).")
        }
    }

    func useItem(named itemName: String, context: AdventureGameContext) {
        if let item = Item(rawValue: itemName.capitalized), inventory.contains(item) {
            context.write("You use the \(item.rawValue), but nothing happens.")
        } else {
            context.write("You don't have a \(itemName).")
        }
    }

    func checkForSpecialConditions(context: AdventureGameContext) {
        // Cursed Ending at Enchanted River
        if currentLocation.name == "Enchanted River" && !inventory.contains(.magicCompass) {
            context.write("You try to cross the river without the Magic Compass. You fall in and are transformed into a tree.")
            gameIsRunning = false
            context.endGame()
        }

        // Interact with Ancient Oak
        if let interactable = currentLocation.interactable {
            let modifiedGame = interactable.interact(context: context, game: self)
            self.currentLocation = modifiedGame.currentLocation
            self.inventory = modifiedGame.inventory
            self.gameMap = modifiedGame.gameMap
            self.gameIsRunning = modifiedGame.gameIsRunning
        }
    }
}
