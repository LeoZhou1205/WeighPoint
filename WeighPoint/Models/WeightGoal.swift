//
//  Goal.swift
//  WeighPoint
//
//  Created by Leo Zhou on 5/10/25.
//

import SwiftData
import Foundation
import SwiftUI

@Model
final class WeightGoal {
    
    enum PreferredStrategy: String, CaseIterable, Codable {
        case eatLess = "Eat Less"
        case balanced = "Balanced"
        case moveMore = "Move More"
        
        var localizedStringKey: LocalizedStringKey {
            switch self {
            case .eatLess:
                return "Eat Less"
            case .balanced:
                return "Balanced"
            case .moveMore:
                return "Move More"
            }
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if container.decodeNil() {
                self = .balanced
            } else {
                let stringValue = try container.decode(String.self)
                self = PreferredStrategy(rawValue: stringValue) ?? .balanced
            }
        }
    }
    
    
    var targetWeightInKg: Double = 0.0
    var targetDate: Date = Date.distantFuture
    var dateSet: Date = Date.distantPast // The date when this goal was created
    
//    var _preferredStrategy: PreferredStrategy? = PreferredStrategy.balanced
//    var preferredStrategy: PreferredStrategy {
//        get {
//            _preferredStrategy ?? .balanced
//        }
//        
//        set {
//            _preferredStrategy = newValue
//        }
//    }
    var preferredStrategyRaw: String = PreferredStrategy.balanced.rawValue
    var preferredStrategy: PreferredStrategy {
        get {
            PreferredStrategy(rawValue: preferredStrategyRaw) ?? .balanced
        }
        set {
            preferredStrategyRaw = newValue.rawValue
        }
    }
    
    
    var active: Bool {
        return Calendar.current.startOfDay(for: .now) < Calendar.current.startOfDay(for: targetDate)
    }

    init(targetWeightInKg: Double, targetDate: Date, dateSet: Date = .now, preferredStrategy: PreferredStrategy = .balanced) {
        self.targetWeightInKg = targetWeightInKg
        self.targetDate = targetDate
        self.dateSet = dateSet
        self.preferredStrategy = preferredStrategy
    }
}
