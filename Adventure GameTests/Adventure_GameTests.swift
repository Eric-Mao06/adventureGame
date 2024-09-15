//
//  Adventure_GameTests.swift
//  Adventure GameTests
//
//  Created by Eric Mao on 9/14/24.
//

import Testing
@testable import Adventure_Game

struct Adventure_GameTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    protocol AdventureGameContext {
        func write(_ string: String)
        func endGame()
    }

}
