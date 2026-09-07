
//
//  MockDataStore.swift
//  WeighPoint
//
//  Created by Alex (AI Assistant) on CurrentDate.
//

import SwiftData
import Foundation

struct MockDataStore {

    // MARK: - Unified Preview Container
    @MainActor
    static func previewContainer() -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        // Ensure all models are registered
        let container: ModelContainer
        do {
            container = try ModelContainer(for: WeightGoal.self, BodyMetricsRecord.self, configurations: config)
        } catch {
            fatalError("Failed to initialize preview container: \(error)")
        }

        // Add mock WeightGoal instances
        container.mainContext.insert(MockDataStore.sampleActiveGoal)
        container.mainContext.insert(MockDataStore.sampleObsoleteGoal)
        
        // Add mock BodyMetricsRecord instances
        let calendar = Calendar.current
        let now = Date()
        let mockRecords: [(dayOffset: Int, weight: Double, height: Double)] = [
            (0, 75, 180), (-1, 77, 180), (-1, 74, 180), (-2, 76, 180),
            (-2, 75, 180), (-3, 73, 180), (-3, 77, 180), (-4, 75, 180),
            (-4, 78, 180), (-6, 76, 178), (-7, 76, 178)
        ]
        
        for mock in mockRecords {
            let date = calendar.date(byAdding: .day, value: mock.dayOffset, to: now)!
            let record = BodyMetricsRecord(date: date, weight: mock.weight, height: mock.height)
            container.mainContext.insert(record)
        }
        
        return container
    }

    // MARK: - Sample Weight Goals
    static var sampleActiveGoal: WeightGoal {
        WeightGoal(targetWeightInKg: 68.0, targetDate: Calendar.current.date(byAdding: .month, value: 2, to: .now)!, dateSet: .now.addingTimeInterval(-86400 * 7), preferredStrategy: .moveMore) // Set a week ago, target 2 months from now
    }

    static var sampleObsoleteGoal: WeightGoal {
        WeightGoal(targetWeightInKg: 72.0, targetDate: Calendar.current.date(byAdding: .month, value: -1, to: .now)!, dateSet: .now.addingTimeInterval(-86400 * 90), preferredStrategy: .balanced) // Set 3 months ago, target 1 month ago
    }
    
    // MARK: - Sample Body Metrics Records (if individual samples are needed elsewhere)
    // You can add static properties or methods for individual mock BodyMetricsRecords if needed
    // For example:
    // static var sampleRecentRecord: BodyMetricsRecord {
    //     BodyMetricsRecord(date: .now, weight: 75, height: 180)
    // }
}
