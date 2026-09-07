//
//  HealthKitEngine.swift
//  WeighPoint
//
//  Created by Leo Zhou on 2/14/26.
//

import Foundation
import HealthKit
import Observation
import UIKit


@Observable
class HealthKitEngine {
    let store = HKHealthStore()
    
    let types: Set = [HKQuantityType(.activeEnergyBurned), HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!]
    
    var sleepEnabled: Bool {
        store.authorizationStatus(for: HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!) == .sharingAuthorized
    }
    
    var workoutLevelEnabled: Bool {
        store.authorizationStatus(for: HKQuantityType(.activeEnergyBurned)) == .sharingAuthorized
    }
    
    var healthKitPermissionAsked: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "hkPermissionAsked")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "hkPermissionAsked")
        }
    }
    
    var showPrimingSheet = false
    private var pendingContinuation: CheckedContinuation<Void, Never>?
    
    var primingSheetButtonText: LocalizedStringResource {
        if healthKitPermissionAsked {
            return "Manage"
        } else {
            return "Connect"
        }
    }
    
    func requestAccess() async {
        if healthKitPermissionAsked { return }
        showPrimingSheet = true
        
        return await withCheckedContinuation { continuation in
            self.pendingContinuation = continuation
        }
    }
    
    func manageAccess() async {
        showPrimingSheet = true
        
        return await withCheckedContinuation { continuation in
            self.pendingContinuation = continuation
        }
    }
    
    @MainActor
    func finishAuthorizationFlow(userSaysYes: Bool) async {
        if userSaysYes {
            if healthKitPermissionAsked == true {
                await UIApplication.shared.open(URL(string: "x-apple-health://")!)
            } else {
                await askForPermission()
            }
        }
        
        healthKitPermissionAsked = true
        showPrimingSheet = false
        
        if let continuation = pendingContinuation {
            continuation.resume()
            pendingContinuation = nil
        }
    }
    
    func askForPermission() async {
        do {
            try await store.requestAuthorization(toShare: [], read: types)
        } catch {
            print("Error Authorizing HealthKit: \(error.localizedDescription)")
        }
    }
    
    
    func getSleepTime() async -> TimeInterval? {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let today = Calendar.current.startOfDay(for: .now)
        let endDate = Calendar.current.date(byAdding: .hour, value: 18, to: today)!
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let startDate = Calendar.current.date(byAdding: .hour, value: 18, to: yesterday)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let descriptor = HKSampleQueryDescriptor(predicates: [.sample(type: sleepType, predicate: predicate)], sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)])
        
        do {
            let samples = try await descriptor.result(for: store)
            var totalSleepTime: TimeInterval = 0
            // guard let samples = samples as? [HKCategoryType] else { return nil }
            for sample in samples {
                //                // Ensure the sample is a Category Sample
                guard let categorySample = sample as? HKCategorySample else { continue }
                
                // Convert the Int value to the Sleep Analysis Enum
                let sleepValue = HKCategoryValueSleepAnalysis(rawValue: categorySample.value)
                
                // Calculate duration of this specific sleep segment
                let duration = categorySample.endDate.timeIntervalSince(categorySample.startDate)
                
                switch sleepValue {
                case .asleepREM, .asleepCore, .asleepDeep, .asleepUnspecified:
                    // Add to total time
                    totalSleepTime += duration
                case .inBed, .awake:
                    // Ignore "In Bed" (it overlaps with sleep stages) and "Awake"
                    continue
                default:
                    continue
                }
            }
            if totalSleepTime == 0 {
                return nil
            }
            return totalSleepTime
        } catch {
            print("Error getting sleep time: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getActiveEnergy() async -> Double? {
        let energyType = HKQuantityType(.activeEnergyBurned)
        let endDate = Calendar.current.startOfDay(for: .now)
        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate)!
        let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: energyType, predicate: queryPredicate)
        let energyQuery = HKStatisticsCollectionQueryDescriptor(predicate: samplePredicate,
                                                               options: .cumulativeSum,
                                                               anchorDate: endDate,
                                                               intervalComponents: .init(day: 1))
        do {
            let energyCounts = try await energyQuery.result(for: store)
            let totalActiveEnergy = energyCounts.statistics().first?.sumQuantity()?.doubleValue(for: .kilocalorie())
            if totalActiveEnergy == 0 {
                return nil
            }
            return totalActiveEnergy
        } catch {
            print("Error getting energy level: \(error.localizedDescription)")
            return nil
        }
        
    }
}
