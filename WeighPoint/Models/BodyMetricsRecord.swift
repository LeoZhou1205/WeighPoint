//
//  BodyMetricsRecord.swift
//  WeighPoint
//
//  Created by Leo Zhou on 5/1/25.
//

import SwiftData
import Foundation

@Model
class BodyMetricsRecord {
    var date: Date = Date()
    var weight: Double = 0.0 // kg
    var height: Double = 0.0 // cm

    init(date: Date, weight: Double, height: Double) {
        self.date = date
        self.weight = weight
        self.height = height
    }

    var bmi: Double {
        guard height > 0 else { return 0 }
        let heightInMeters = height / 100
        guard heightInMeters > 0 else { return 0 }
        return weight / (heightInMeters * heightInMeters)
    }
}


//// MARK: - Mock Data (Optional, for previews and testing)
//extension BodyMetricsRecord {
//    @MainActor
//    static func mockContainer() -> ModelContainer {
//        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//        let container = try! ModelContainer(for: BodyMetricsRecord.self, configurations: config)
//        
//        let calendar = Calendar.current
//        let now = Date()
//
//        // Add mock records
//        let mocks: [(dayOffset: Int, weight: Double, height: Double)] = [
//            (0, 75, 180),
//            (-1, 77, 180),
//            (-1, 74, 180),
//            (-2, 76, 180),
//            (-2, 75, 180),
//            (-3, 73, 180),
//            (-3, 77, 180),
//            (-4, 75, 180),
//            (-4, 78, 180),
//            (-6, 76, 178),
//            (-7, 76, 178)
//        ]
//        
//        for mock in mocks {
//            let date = calendar.date(byAdding: .day, value: mock.dayOffset, to: now)!
//            let record = BodyMetricsRecord(date: date, weight: mock.weight, height: mock.height)
//            container.mainContext.insert(record)
//        }
//        
//        return container
//    }
//}
