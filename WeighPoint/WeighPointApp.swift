//
//  WeighPointApp.swift
//  WeighPoint
//
//  Created by Leo Zhou on 5/1/25.
//

import SwiftUI
import SwiftData

@main
struct WeighPointApp: App {
    var modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: BodyMetricsRecord.self, WeightGoal.self)
        } catch {
            fatalError("Cannot set up container: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(modelContainer)
//        .modelContainer(MockDataStore.previewContainer())
    }
}
