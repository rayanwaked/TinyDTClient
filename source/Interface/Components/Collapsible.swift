//
//  Collapsible.swift
//  TinyDTClient
//
//  Created by Rayan Waked on 5/30/24.
//

import SwiftUI

// MARK: - Collapsible View
struct Collapsible<Content: View>: View {
    // State Variables
    @State private var isExpanded: Bool = true

    // Properties
    let buttonText: String
    let expandedButtonText: String
    let content: () -> Content

    // MARK: - Body
    var body: some View {
        VStack {
            // Toggle Button
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(isExpanded ? expandedButtonText : buttonText)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
            }

            // Collapsible Content
            if isExpanded {
                content()
                    .padding()
                    .transition(.scale)
            }
        }
        .padding()
    }
}
