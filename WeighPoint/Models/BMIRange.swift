//
//  BMIRange.swift
//  WeighPoint
//
//  Created by Leo Zhou on 5/1/25.
//

import SwiftUI

struct BMIRange: Identifiable {
    let id = UUID()
    let title: LocalizedStringResource
    let start: Double
    let end: Double
    let color: Color
    var rangeText: String {
        if start == 0.0 {
            return "<\(end)"
        }
        if end == .infinity {
            return ">\(start)"
        }
        return "\(start) - \(end - 0.1)"
    }
    
    func contains(_ bmi: Double) -> Bool {
        return start <= bmi && bmi < end
    }
    
    static let all: [BMIRange] = [
        BMIRange(title: "Underweight", start: 0, end: 18.5, color: .underweight),
        BMIRange(title: "Normal weight", start: 18.5, end: 25.0, color: .accent),
        BMIRange(title: "Overweight", start: 25.0, end: 30.0, color: .yellow),
        BMIRange(title: "Obese", start: 30.0, end: .infinity, color: .orange)
        ]
}
