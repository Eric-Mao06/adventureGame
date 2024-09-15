//
//  ContentView.swift
//  Adventure Game
//
//  Created by Eric Mao on 9/14/24.
//

import SwiftUI

struct ContentView: View {
    @State private var game = GameLogic()
    @State private var userInput: String = ""
    @State private var outputText: String = ""
    @FocusState private var isInputActive: Bool

    var body: some View {
        VStack {
            ScrollViewReader { scrollView in
                ScrollView {
                    Text(outputText)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .id("OutputText")
                }
                .background(Color(UIColor.systemBackground))
                .onChange(of: outputText) {
                    withAnimation {
                        scrollView.scrollTo("OutputText", anchor: .bottom)
                    }
                }
            }

            Divider()

            HStack {
                TextField("Enter command...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .focused($isInputActive)
                    .onSubmit {
                        handleInput()
                    }

                Button(action: handleInput) {
                    Text("Submit")
                }
                .padding(.trailing)
            }
            .background(Color(UIColor.secondarySystemBackground))
        }
        .onAppear {
            game.start(context: GameContext(outputText: $outputText))
        }
        .onTapGesture {
            isInputActive = false
        }
    }

    func handleInput() {
        game.handle(input: userInput, context: GameContext(outputText: $outputText))
        userInput = ""
    }
}

struct GameContext: AdventureGameContext {
    @Binding var outputText: String

    func write(_ string: String) {
        DispatchQueue.main.async {
            outputText += "\n\n" + string
        }
    }

    func endGame() {
        // Handle game over state if needed
    }
}


