//
//  ContentView.swift
//  TinyDTClient
//


import SwiftUI

// MARK: - ContentView Struct
struct ContentView: View {
  let serverConfig = ServerConfig()
  @State var prompt: String = ""
  @ObservedObject var requester = SimpleImageRequester.shared

    var body: some View {
        VStack {
          textInput

          imageOutput
        }
        .padding()
    }
  }


// MARK: - UI Modules
private extension ContentView {
    // MARK: - Text Input
    var textInput: some View {
        TextField("Prompt:", text: $prompt).onSubmit {
            requester.runPrompt(prompt)
        }
    }
    
    // MARK: - Image Output
    var imageOutput: some View {
        Collapsible(buttonText: "Show", expandedButtonText: "Hide") {
            Group {
                if let image = requester.image {
                    Image(nsImage: image)
                } else {
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

