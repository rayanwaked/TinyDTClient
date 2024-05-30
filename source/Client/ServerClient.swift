//
//  TinyDTClient.swift
//
//  Created by SoDoTo on 1/11/24.
//  Cloned and copied from PromptWriter Main
//  Built on "RealHTTP" network client library
//  https://github.com/immobiliare/RealHTTP
//

import Foundation
import RealHTTP
import SwiftUI

// MARK: - Server Config
class ServerConfig {
    var serverPath = "/sdapi/v1/txt2img"
    var defaultServerBaseURL = "localhost:7860"
    let defaultServerPrefix = "http://"
}

// MARK: - SimpleDTClient Class
class SimpleDTClient: ObservableObject {
    // Published Variables
    @Published var status: ServerStatus = .unknown
    
    // Constants and Variables
    let serverConfig = ServerConfig()
    static let shared = SimpleDTClient()
    
    enum ServerStatus: Int {
        case unknown = 0, serverUp, serverDown
    }
    
    enum RequestStatus: Int {
        case requestOK = 0, requestCancelled, requestError, requestServerDown
    }

    init(thisDevice: Bool = true, address: String = "") {
        serverConfig.defaultServerBaseURL = thisDevice ? serverConfig.defaultServerBaseURL : address
        status = getServerStatusAsync()
    }
    
    // MARK: - Public Methods
    /// Runs a prompt request to the server with the specified positive and negative prompts.
    /// - Parameters:
    ///   - posPrompt: The positive prompt text to be sent to the server.
    ///   - negPrompt: The negative prompt text to be sent to the server (default is an empty string).
    func runPrompt(_ posPrompt: String, negPrompt: String = "") {
        let dictionary: [String: Any?] = ["prompt": posPrompt, "negative_prompt": negPrompt, "seed": -1]
        do {
            let json = try HTTPBody.json(dictionary)
            if let req = createJSONRequest(json: json) {
                runRequest(req)
            }
        } catch {
            return
        }
    }

    
    // MARK: - Get Server Status
    /// Asynchronously checks the server status by sending a HEAD request.
    /// - Returns: The current status of the server (ServerStatus).
    func getServerStatusAsync() -> ServerStatus {
        let req = HTTPRequest {
            $0.url = URL(string: serverConfig.defaultServerPrefix + serverConfig.defaultServerBaseURL)
            $0.method = .head
            $0.timeout = 5
            $0.allowsCellularAccess = true
        }
        req.headers = HTTPHeaders()

        Task {
            do {
                let response = try await req.fetch()
                let newStatus: ServerStatus = response.statusCode != .none ? .serverUp : .serverDown
                if status != newStatus {
                    DispatchQueue.main.async {
                        self.status = newStatus
                    }
                }
                return newStatus
            } catch {
                print("Error fetching request: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.status = .serverDown
                }
                return .serverDown
            }
        }
        return status
    }
    
    // MARK: - Private Methods
    /// Creates a JSON request with specified parameters for interacting with the server.
    /// - Parameters:
    ///   - json: The HTTPBody containing the JSON data to be sent in the request.
    /// - Returns: An optional HTTPRequest object configured with the specified parameters. If the URL is invalid, it returns nil.
    private func createJSONRequest(json: HTTPBody) -> HTTPRequest? {
        guard let url = URL(string: serverConfig.defaultServerPrefix + serverConfig.defaultServerBaseURL + serverConfig.serverPath) else { return nil }
        return HTTPRequest {
            $0.url = url
            $0.method = .post
            $0.timeout = 10000
            $0.allowsCellularAccess = true
            $0.body = json
        }
    }

    // MARK: - Run Request
    /// Sends an HTTP request to the server and processes the response asynchronously.
    /// - Parameters:
    ///    - req: The HTTPRequest object to be sent to the server.
    private func runRequest(_ req: HTTPRequest) {
        struct JSONImageArray: Codable {
            var images: [Data]
        }

        Task {
            do {
                let response = try await req.fetch()
                guard response.statusCode == .ok, let rawResponse = response.data else { return }
                let decoder = JSONDecoder()
                let jsonImages = try decoder.decode(JSONImageArray.self, from: rawResponse)
                guard let imageData = jsonImages.images.first else { return }

                DispatchQueue.main.async {
                    SimpleImageRequester.shared.returnImage(imageData)
                }
            } catch {
                print("Error fetching HTTP request: \(error)")
            }
        }
    }
}
