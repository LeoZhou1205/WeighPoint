//
//  SwiftDataService.swift
//  WeighPoint
//
//  Created by Leo Zhou on 5/30/25.
//
import SwiftData
import Foundation


class SwiftDataService {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    @MainActor
    static let shared = SwiftDataService()
    
    @MainActor
    private init() {
        // Change isStoredInMemoryOnly to false if you would like to see the data persistance after kill/exit the app
        self.modelContainer = try! ModelContainer(for: BodyMetricsRecord.self, WeightGoal.self)
        self.modelContext = modelContainer.mainContext
    }
    
    @MainActor
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
    }
    
    func fetchOrderedBodyMetricsRecord() -> [BodyMetricsRecord] {
        do {
            let descriptor = FetchDescriptor<BodyMetricsRecord>(
                sortBy: [SortDescriptor(\.date)]
            )
            return try modelContext.fetch(descriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func fetchWeightGoal() -> [WeightGoal] {
        do {
            let descriptor = FetchDescriptor<WeightGoal>(
                sortBy: [SortDescriptor(\.dateSet, order: .reverse)]
            )
            return try modelContext.fetch(descriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func addBodyMetricsData(_ bodyMetricsData: BodyMetricsRecord) {
        modelContext.insert(bodyMetricsData)
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func addWeightGoal(_ weightGoal: WeightGoal) {
        modelContext.insert(weightGoal)
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
