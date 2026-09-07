//
//  PlanetWeightInsight.swift
//  WeighPoint
//
//  Created by Leo Zhou on 6/1/25.
//
import Foundation


struct PlanetWeightInsight: Insight {
    var id: UUID = UUID()
    var title: LocalizedStringResource {
        "Your Weight on \(planet.rawValue)"
    }
    var icon: String = "🚀"
    var message: LocalizedStringResource {
        planet.insightMessage
    }
    
    var priority: InsightPriority
    
    var planetWeight: Double {
        planet.planetWeight(from: WeightUnit.convert(weightInKg, from: .kilograms, to: weightUnit))
    }
    
    var displayedPlanetWeight: String {
        "\(planetWeight.formatted(.number.precision(.fractionLength(1)))) \(weightUnit.rawValue)"
    }
    
    var planet: Planet
    var weightInKg: Double
    var weightUnit: WeightUnit
    
    enum Planet: LocalizedStringResource, CaseIterable {
        case mars = "Mars"
        case jupiter = "Jupiter"
        case venus = "Venus"
        
        var gravity: Double {
            switch self {
            case .mars:
                return 3.73
            case .jupiter:
                return 24.79
            case .venus:
                return 8.87
            }
        }
        
        var systemImage: String {
            switch self {
            case .mars:
                return "balloon.2.fill"
            case .jupiter:
                return "arrow.down.to.line.compact"
            case .venus:
                return "thermometer.high"
            }
        }
        
        var insightMessage: LocalizedStringResource {
            switch self {
            case .mars:
                return "Light enough to win every high jump competition… and maybe float away if you're not careful"
            case .jupiter:
                return "So heavy you'd need a crane just to get out of bed! Good thing it's mostly gas."
            case .venus:
                return "But don't pack your bags, it's 900°F there and rains sulfuric acid!"
            }
        }
        
        func planetWeight(from weightOnEarth: Double) -> Double {
            return weightOnEarth * gravity / 9.81
        }
    }
}
