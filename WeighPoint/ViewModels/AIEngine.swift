//
//  AIEngine.swift
//  WeighPoint
//
//  Created by Leo Zhou on 2/7/26.
//

import Foundation


class AIEngine {
    
    struct GeminiRequest: Encodable {
        let system_instruction: GeminiSystemInstruction?
        let contents: [GeminiContent]
        let generationConfig: GeminiGenerationConfig?
    }
    
    struct GeminiSystemInstruction: Encodable {
        let parts: [GeminiPart]
    }
    
    struct GeminiContent: Codable {
        let parts: [GeminiPart]
    }
    
    struct GeminiPart: Codable {
        let text: String
    }
    
    struct GeminiGenerationConfig: Encodable {
        let thinkingConfig: GeminiThinkingConfig
    }
    
    struct GeminiThinkingConfig: Encodable {
        enum ThinkingLevel: String, Encodable { case low, high }
        let thinkingLevel: ThinkingLevel
    }
    
    struct GeminiResponse: Decodable {
        let candidates: [GeminiCandidate]
    }
    
    struct GeminiCandidate: Decodable {
        let content: GeminiContent
    }
    
    
    
    private let apiKey: String
    let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent"
    
    
    func request(withPrompt prompt: String) async -> String? {
        
        guard !apiKey.isEmpty, let url = URL(string: urlString) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
        let requestBody = GeminiRequest(system_instruction: nil, contents: [GeminiContent(parts: [GeminiPart(text: prompt)])], generationConfig: GeminiGenerationConfig(thinkingConfig: GeminiThinkingConfig(thinkingLevel: .low)))
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Server Error: \(response)")
                return nil
            }
            if let response = try? JSONDecoder().decode(GeminiResponse.self, from: data) {
                return response.candidates.first?.content.parts.first?.text
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        return nil
    }
    
    func request(withPrompt prompt: String, andSystemInstruction systemInstruction: String) async -> String? {
        
        guard !apiKey.isEmpty, let url = URL(string: urlString) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
        let requestBody = GeminiRequest(system_instruction: GeminiSystemInstruction(parts: [GeminiPart(text: systemInstruction)]), contents: [GeminiContent(parts: [GeminiPart(text: prompt)])], generationConfig: GeminiGenerationConfig(thinkingConfig: GeminiThinkingConfig(thinkingLevel: .low)))
        do {
            let encoder = JSONEncoder()
            // encoder.keyEncodingStrategy = .convertToSnakeCase
            request.httpBody = try encoder.encode(requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Server Error: \(response)")
                return nil
            }
            if let response = try? JSONDecoder().decode(GeminiResponse.self, from: data) {
                return response.candidates.first?.content.parts.first?.text
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        return nil
    }
    
    init(apiKey: String) {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        // A checkout without local configuration must not send an invalid key.
        self.apiKey = trimmedKey.hasPrefix("$(") ? "" : trimmedKey
    }
    
    static let shared = AIEngine(
        apiKey: Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String ?? ""
    )
}
