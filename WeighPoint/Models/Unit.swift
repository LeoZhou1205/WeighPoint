//
//  Unit.swift
//  WeighPoint
//
//  Created by Leo Zhou on 5/2/25.
//

import Foundation


protocol Unit: CaseIterable, RawRepresentable, Hashable where RawValue == String {
    func convert(_ value: Double, to unit: Self) -> Double
    static func convert(_ value: Double, from unit1: Self, to unit2: Self) -> Double
    static var systemDefault: Self { get }
}

enum HeightUnit: String, Unit, CaseIterable {
    
    case centimeters = "cm"
    case inches = "ft"
    
    static var systemDefault: HeightUnit {
        Locale.current.measurementSystem == .metric ? .centimeters : .inches
    }
    
    func convert(_ value: Double, to unit: HeightUnit) -> Double {
        switch (self, unit) {
        case (.inches, .centimeters):
            return value * 2.54  // inches to cm
        case (.centimeters, .inches):
            return value / 2.54  // cm to inches
        default:
            return value
        }
    }
    
    static func convert(_ value: Double, from unit1: HeightUnit, to unit2: HeightUnit) -> Double {
        switch (unit1, unit2) {
        case (.inches, .centimeters):
            return value * 2.54  // inches to cm
        case (.centimeters, .inches):
            return value / 2.54  // cm to inches
        default:
            return value
        }
    }
    
}

enum WeightUnit: String, Unit, CaseIterable {
    
    case kilograms = "kg"
    case pounds = "lbs"
    
    static var systemDefault: WeightUnit {
        Locale.current.measurementSystem == .metric ? .kilograms : .pounds
    }
    
    func convert(_ value: Double, to unit: WeightUnit) -> Double {
        switch (self, unit) {
        case (.pounds, .kilograms):
            return value * 0.453592
        case (.kilograms, .pounds):
            return value * 2.20462
        default:
            return value
        }
    }
    
    static func convert(_ value: Double, from unit1: WeightUnit, to unit2: WeightUnit) -> Double {
        switch (unit1, unit2) {
        case (.pounds, .kilograms):
            return value * 0.453592
        case (.kilograms, .pounds):
            return value * 2.20462
        default:
            return value
        }
    }
}
