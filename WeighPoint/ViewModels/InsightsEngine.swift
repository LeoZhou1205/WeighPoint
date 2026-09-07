//
//  InsightsEngine.swift
//  WeighPoint
//
//  Created by Leo Zhou on 5/25/25.
//

import Foundation
import SwiftData
import Algorithms
import SwiftUI
import Observation
import CloudStorage

struct DefaultInsight: Insight {
    var id: UUID = UUID()
    
    var title: LocalizedStringResource
    
    var icon: String
    
    var message: LocalizedStringResource
    
    var priority: InsightPriority
}

@MainActor
@Observable
class InsightsEngine {
    var insights: [any Insight] = []
    var aiInsight: AIGeneratedInsight?
    
    var aiEnabld: Bool {
        get {
            return NSUbiquitousKeyValueStore.default.bool(forKey: "aiEnabled")
        }
        
        set {
            NSUbiquitousKeyValueStore.default.set(newValue, forKey: "aiEnabled")
        }
    }
    
    var aiPermissionAsked: Bool {
        get {
            return NSUbiquitousKeyValueStore.default.bool(forKey: "aiPermissionAsked")
        }
        
        set {
            NSUbiquitousKeyValueStore.default.set(newValue, forKey: "aiPermissionAsked")
        }
    }
    
    var askForAI: Bool = false
    
    private var pendingContinuation: CheckedContinuation<Void, Never>?
    
    func requestAccessForAI() async {
        if aiPermissionAsked { return }
        askForAI = true
        
        return await withCheckedContinuation { continuation in
            self.pendingContinuation = continuation
        }
    }
    
    func finishAuthorizationFlow(userSaysYes: Bool) {
        if userSaysYes {
            aiEnabld = true
        }
        
        aiPermissionAsked = true
        askForAI = false
        
        if let continuation = pendingContinuation {
            continuation.resume()
            pendingContinuation = nil
        }
    }
    
    private var dataSource: SwiftDataService?
    
    init() {
        // No dataSource initialization here - will be set when needed
    }
    
    func initialize(with modelContext: ModelContext) {
        if dataSource == nil {
            dataSource = SwiftDataService(modelContainer: modelContext.container)
        }
    }
    
    func loadAIInsight(weightRecords: [(Double, Double)]?, sleepTime: Double?, activeEnergy: Double?) async {
        if let loadedTextPair = await AIGeneratedInsight.loadTextPair(withPrompt: AIGeneratedInsight.generatePrompt(weightRecords: weightRecords, sleepTime: sleepTime, activeEnergy: activeEnergy)) {
            withAnimation {
                aiInsight = .init(headline: loadedTextPair.headline, insight: loadedTextPair.insight, actionItems: loadedTextPair.actionItems)
            }
        }
    }
    
    func forceReloadAIInsight(weightRecords: [(Double, Double)]?, sleepTime: Double?, activeEnergy: Double?) async {
        
    }
    
    func reloadAllInsights() {
        
        print("Insight Reload Triggered")
        
        guard let dataSource = dataSource else { return }
        
        
        let sortedRecords = dataSource.fetchOrderedBodyMetricsRecord()
        // let sortedRecords = records.sorted { $0.date < $1.date }
        let weightGoal = dataSource.fetchWeightGoal().first { $0.active }
        guard !sortedRecords.isEmpty else {
            insights = [DefaultInsight(title: "Keep Tracking Your Health", icon: "✨", message: "We need a bit more data before we can offer insights. Keep logging your records to unlock personalized trends!", priority: .medium)]
            return
        }
        
        var newInsights: [any Insight] = []
        
        let planet = PlanetWeightInsight.Planet.allCases.randomElement() ?? .mars
        
        newInsights.append(PlanetWeightInsight(priority: .low, planet: planet, weightInKg: sortedRecords.last!.weight, weightUnit: .kilograms))
        newInsights.append(BMIInsight(priority: .high, bmi: sortedRecords.last!.bmi))
        if let weightGoal = weightGoal {
            var targetStartWeightInKg = 0.0
            for record in sortedRecords {
                if record.date < weightGoal.dateSet {
                    targetStartWeightInKg = record.weight
                } else {
                    break
                }
            }
            
            let indexFirstAfter = sortedRecords.partitioningIndex { $0.date > weightGoal.dateSet }
            if indexFirstAfter == sortedRecords.count || (indexFirstAfter > 0 && weightGoal.dateSet.timeIntervalSince(sortedRecords[indexFirstAfter-1].date) < 3600 * 24 * 2) {
                targetStartWeightInKg = sortedRecords[indexFirstAfter - 1].weight
            } else {
                targetStartWeightInKg = sortedRecords[indexFirstAfter].weight
            }
            
            if targetStartWeightInKg > 0 {
                newInsights.append(WeightChangeProgressInsight(priority: .medium, targetWeightInKg: weightGoal.targetWeightInKg, currentWeightInKg: sortedRecords.last!.weight, targetStartWeightInKg: targetStartWeightInKg, weightUnit: .kilograms))
            }
            
            let gender = Gender(rawValue: Int(NSUbiquitousKeyValueStore.default.longLong(forKey: "userGender"))) ?? .preferNotToSay
            let birthYear = NSUbiquitousKeyValueStore.default.longLong(forKey: "userBirthYear")
            let age = birthYear == 0 ? nil : Calendar.current.component(.year, from: .now) - Int(birthYear)
            let goalStrategyInsight = GoalStrategyInsight(currentWeightInKg: sortedRecords.last!.weight, heightInCm: sortedRecords.last!.height, age: age, gender: gender, targetWeightInKg: weightGoal.targetWeightInKg, targetDate: weightGoal.targetDate, preferredStrategy: weightGoal.preferredStrategy)
            newInsights.append(goalStrategyInsight)
        }
        
        insights = newInsights.sorted { $0.priority.rawValue > $1.priority.rawValue }
    }
    
    func reloadBMIRelatedInsights(bmi: Double) {
        var bmiInsightExist = false
        for i in 0..<insights.count {
            if var insight = insights[i] as? BMIInsight {
                insight.bmi = bmi
                insights[i] = insight
                bmiInsightExist = true
                break
            }
        }
        if !bmiInsightExist {
            insights.append(BMIInsight(priority: .high, bmi: bmi))
            insights.sort { $0.priority.rawValue > $1.priority.rawValue }
        }
    }
}
