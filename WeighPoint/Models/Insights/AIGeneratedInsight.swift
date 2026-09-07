//
//  AIGeneratedInsight.swift
//  WeighPoint
//
//  Created by Leo Zhou on 2/7/26.
//

import Foundation


struct AIGeneratedInsight {
    var id: UUID = UUID()
    
    var lastUpdateDate: Date
    
    var textPair: TextPair
    
    struct TextPair: Decodable {
        let headline: String
        let insight: String
        let actionItems: [String]
    }
    
    init(id: UUID = UUID(), lastUpdateDate: Date = .now, headline: String, insight: String, actionItems: [String]) {
        self.id = id
        self.lastUpdateDate = lastUpdateDate
        self.textPair = .init(headline: headline, insight: insight, actionItems: actionItems)
    }
    
    static func reloadTextPair(withPrompt prompt: String) async -> TextPair? {
        let returnedText = await AIEngine.shared.request(withPrompt: prompt, andSystemInstruction: AIGeneratedInsight.systemInstruction)
        if let returnedTextInJson = returnedText?.data(using: .utf8) {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let decodedTextPair = try decoder.decode(TextPair.self, from: returnedTextInJson)
                NSUbiquitousKeyValueStore.default.set(Date(), forKey: "aiGeneratedInsightLastUpdateDate")
                NSUbiquitousKeyValueStore.default.set(decodedTextPair.headline, forKey: "aiGeneratedInsightTextPairHeadline")
                NSUbiquitousKeyValueStore.default.set(decodedTextPair.insight, forKey: "aiGeneratedInsightTextPairInsight")
                NSUbiquitousKeyValueStore.default.set(decodedTextPair.actionItems, forKey: "aiGeneratedInsightTextPairActionItems")
                return decodedTextPair
            } catch {
                print("Error: \(error.localizedDescription); returned text: \(String(describing: returnedText))")
            }
        } else {
            print("Cannot convert text to JSON")
        }
        return nil
    }
    
    static func loadTextPair(withPrompt prompt: String) async -> TextPair? {
        
        let lastUpdateDate = NSUbiquitousKeyValueStore.default.object(forKey: "aiGeneratedInsightLastUpdateDate") as? Date ?? .distantPast
        if lastUpdateDate.timeIntervalSinceNow > -3600, let headline = NSUbiquitousKeyValueStore.default.string(forKey: "aiGeneratedInsightTextPairHeadline"), let insight = NSUbiquitousKeyValueStore.default.string(forKey: "aiGeneratedInsightTextPairInsight"), let actionItems = NSUbiquitousKeyValueStore.default.array(forKey: "aiGeneratedInsightTextPairActionItems") as? [String] {
            return .init(headline: headline, insight: insight, actionItems: actionItems)
        } else {
            let returnedText = await AIEngine.shared.request(withPrompt: prompt, andSystemInstruction: AIGeneratedInsight.systemInstruction)
            if let returnedTextInJson = returnedText?.data(using: .utf8) {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let decodedTextPair = try decoder.decode(TextPair.self, from: returnedTextInJson)
                    NSUbiquitousKeyValueStore.default.set(Date(), forKey: "aiGeneratedInsightLastUpdateDate")
                    NSUbiquitousKeyValueStore.default.set(decodedTextPair.headline, forKey: "aiGeneratedInsightTextPairHeadline")
                    NSUbiquitousKeyValueStore.default.set(decodedTextPair.insight, forKey: "aiGeneratedInsightTextPairInsight")
                    NSUbiquitousKeyValueStore.default.set(decodedTextPair.actionItems, forKey: "aiGeneratedInsightTextPairActionItems")
                    return .init(headline: decodedTextPair.headline, insight: decodedTextPair.insight, actionItems: decodedTextPair.actionItems)
                } catch {
                    print("Error: \(error.localizedDescription); returned text: \(String(describing: returnedText))")
                }
            } else {
                print("Cannot convert text to JSON")
            }
            
            
            return nil
        }
    }
    
    
    
    static let promptExample = """
            Here is the user's current data:
            - Weight Trend: {(75, -10), (76.5, -86400))}
            - Sleep Time: {5h}
            - Workout Level: {1000kcal}
        
            Generate the insight JSON.
    """
    
    static func generatePrompt(weightRecords: [(Double, Double)]?, sleepTime: Double?, activeEnergy: Double?) -> String {
        let weightRecordsDescription = weightRecords == nil ? "Not Available" : String(describing: weightRecords)
        let sleepTimeDescription = sleepTime == nil ? "Not Available" : String(describing: sleepTime!/3600)
        let activeEnergyDescription = activeEnergy == nil ? "Not Available" : String(describing: activeEnergy!)
        return """
        Here is the user's current data:
        - Weight Trend: {\(weightRecordsDescription)}
        - Sleep Time: {\(sleepTimeDescription)h}
        - Workout Level: {\(activeEnergyDescription)kcal}
    
        Generate the insight JSON.
    """
    }
    
    static let systemInstruction = """
        You are the WeighPoint Intelligence Engine, a data-driven sports physiologist. Your goal is to analyze specific biometrics to provide a single, high-value insight for a premium user.
        
          ### INPUT DATA INTERPRETATION
          1. Weight Records: You will receive the last 5 weights (in kg) with time labels (offset in hours). Analyze the *trend* (Spike, Drop, Plateau) relative to the most recent entry.
          2. Sleep Duration: You must judge the quality. <6h is Poor (Cortisol risk), 6-7h is Fair, >7h is Optimal (Recovery).
          3. Calories Burnt: Judge the strain. <400 is Active Recovery/Sedentary, 400-800 is Moderate, >800 is High Intensity (Inflammation risk).
        
          ### OUTPUT REQUIREMENTS (JSON format, no additional text)
          1. "headline" (2-4 words, Max 20 chars):
             - A medical/physiological status. NO verbs.
             - Examples: "Glycogen Supercompensation", "CNS Fatigue", "Fluid Retention", "Metabolic Prime".
          
          2. "insight" (10-15 words):
             - Explain the CAUSE of the weight trend based on Sleep and Calories.
             - Use terms like: Cortisol, Inflammation, Water Weight, Glycogen, Repair.
             - If Weight is UP + High Cals: Mention muscle water retention.
             - If Weight is UP + Low Sleep: Mention stress/cortisol storage.
          
          3. "action_items" (Array of 1-2 strings, max 4 words each):
             - Specific fixes.
             - Examples: ["Hydrate +3L", "Nap 20mins", "Eat High Protein"].
        
          ### FORMAT
          {
            "headline": "String",
            "insight": "String",
            "action_items": ["String", "String"]
          }
        """
}
