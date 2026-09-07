//
//  BMIInsight.swift
//  WeighPoint
//
//  Created by Leo Zhou on 6/1/25.
//
import Foundation

struct BMIInsight: Insight {
    var id: UUID = UUID()
    var title: LocalizedStringResource = "Your Latest BMI"
    var icon: String = "💪"
    var message: LocalizedStringResource = "A typical healthy BMI is between 18.5 and 24.9, but everyone's body is different"
    
    var priority: InsightPriority
    
    var bmi: Double
    var displayedBMI: String {
        bmi.formatted(.number.precision(.fractionLength(1)))
    } // e.g. "23.0"
    
    var bmiRange: BMIRange {
        BMIRange.all.first { $0.contains(bmi) } ?? BMIRange.init(title: "Unknown BMI Range", start: .zero, end: .infinity, color: .gray)
    }
    
    var displayedBMIRange: LocalizedStringResource {
        bmiRange.title
    }
    
}
