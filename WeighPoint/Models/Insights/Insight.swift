//
//  Insight.swift
//  WeighPoint
//
//  Created by Leo Zhou on 5/25/25.
//

import Foundation

enum InsightCategory {
    case bmi
    case fun
    case health
    case progress
}

enum InsightPriority: Int, CaseIterable {
    case low = 0
    case medium = 1
    case high = 2
}

protocol Insight: Identifiable {
    var id: UUID { get }
    var title: LocalizedStringResource { get }
    var icon: String { get }
    var message: LocalizedStringResource { get }
    
    var priority: InsightPriority { get }
}

