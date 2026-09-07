//
//  WeightChangeProgressInsight.swift
//  WeighPoint
//
//  Created by Leo Zhou on 6/1/25.
//

import Foundation


struct WeightChangeProgressInsight: Insight {
    var id: UUID = UUID()
    var title: LocalizedStringResource = "Progress So Far"
    var icon: String = "🎯"

    
    var priority: InsightPriority
        
    var progress: Double { currentWeight - targetStartWeight }
    var goal: Double { targetWeight - targetStartWeight }
    var progressPercentage: Double { goal == 0 ? 1.0 : (progress / goal) * 100 }
    var roundedPercentage: Int { Int(progressPercentage.rounded()) }
    
    var motivationText: LocalizedStringResource {
        switch roundedPercentage {
        case 0...90:
            return "keep it up!"
        default:
            return "absolutely crushing it!"
        }
    }
    
    var message: LocalizedStringResource {
        "You reached \(roundedPercentage)% of your goal - \(motivationText)"
    }
    
    var targetWeightInKg: Double
    var targetWeight: Double { WeightUnit.convert(targetWeightInKg, from: .kilograms, to: weightUnit) }
    
    var currentWeightInKg: Double
    var currentWeight: Double { WeightUnit.convert(currentWeightInKg, from: .kilograms, to: weightUnit) }

    var targetStartWeightInKg: Double
    var targetStartWeight: Double { WeightUnit.convert(targetStartWeightInKg, from: .kilograms, to: weightUnit) }

    var weightUnit: WeightUnit

}
