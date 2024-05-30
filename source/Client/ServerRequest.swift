//
//  ServerRequest.swift
//  TinyDTClient
//
//  Created by Rayan Waked on 5/30/24.
//

import SwiftUI

// MARK: - SimpleImageRequester Class
class SimpleImageRequester: ObservableObject {
    static let shared = SimpleImageRequester()  // Singleton instance for global access

    // Published Variables
    @Published var image: NSImage?

    // MARK: - Public Methods
    /// Runs a prompt request using the shared SimpleDTClient instance.
    /// - Parameters:
    ///   - prompt: The prompt text to be sent to the server.
    func runPrompt(_ prompt: String) {
        SimpleDTClient.shared.runPrompt(prompt)
    }

    /// Sets the received image data to the published image property.
    /// - Parameters:
    ///   - imageData: The image data received from the server.
    func returnImage(_ imageData: Data) {
        self.image = NSImage(data: imageData)
    }

    /// Saves the received image data temporarily to the file system.
    /// - Parameters:
    ///   - imageData: The image data to be saved.
    /// - Returns: The URL of the temporarily saved image file, or nil if the save operation fails.
    func saveTmpImage(_ imageData: Data) -> URL? {
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectoryURL.appendingPathComponent("tmpImage.png")

        do {
            try imageData.write(to: tempFileURL)
        } catch {
            return nil
        }
        return tempFileURL
    }
}
