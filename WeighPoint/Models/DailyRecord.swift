//
//  DailyRecord.swift
//  WeighPoint
//
//  Created by Leo Zhou on 5/2/25.
//

import Foundation

struct DailyRecord: Identifiable {
    
    struct RecordEntry: Comparable {
        static func < (lhs: DailyRecord.RecordEntry, rhs: DailyRecord.RecordEntry) -> Bool {
            return lhs.value < rhs.value
        }
        
        var value: Double
        var time: Date
    }
    
    var id: UUID = UUID()
    var date: Date
    var bmiValues: [RecordEntry]
    var weightValues: [RecordEntry]
    var weightUnit: WeightUnit
    
    var maxBMI: Double {
        bmiValues.max()?.value ?? 0.0
    }
    
    var maxBMIRecordingTime: Date {
        bmiValues.max()?.time ?? date
    }
    
    var minBMI: Double {
        bmiValues.min()?.value ?? 0.0
    }
    
    var minBMIRecordingTime: Date {
        bmiValues.min()?.time ?? date
    }
    
    var averageBMI: Double {
        guard bmiValues.count != 0 else {
            return 0.0
        }
        return bmiValues.reduce(0.0) { result, entry in
            result + entry.value
        } / Double(bmiValues.count)
    }
    
    var maxWeight: Double {
        weightValues.max()?.value ?? 0.0
    }
    
    var maxWeightRecordingTime: Date {
        weightValues.max()?.time ?? date
    }
    
    var minWeight: Double {
        weightValues.min()?.value ?? 0.0
    }
    
    var minWeightRecordingTime: Date {
        weightValues.min()?.time ?? date
    }
    
    var averageWeight: Double {
        guard weightValues.count != 0 else {
            return 0.0
        }
        return weightValues.reduce(0.0) { result, entry in
            result + entry.value
        } / Double(weightValues.count)
    }
    
    static func fromBodyMetricsRecords(_ bodyMetricsRecords: [BodyMetricsRecord], targetUnit: WeightUnit = .kilograms) -> [DailyRecord] {
        var startDate = Date.distantPast
        var dailyRecords: [DailyRecord] = []
        for record in bodyMetricsRecords {
            if Calendar.current.isDate(record.date, inSameDayAs: startDate) {
                dailyRecords[dailyRecords.count - 1].bmiValues.append(DailyRecord.RecordEntry(value: record.bmi, time: record.date))
                dailyRecords[dailyRecords.count - 1].weightValues.append(DailyRecord.RecordEntry(value: WeightUnit.convert(record.weight, from: .kilograms, to: targetUnit), time: record.date))
            } else {
                startDate = Calendar.current.startOfDay(for: record.date)
                dailyRecords.append(DailyRecord(date: startDate, bmiValues: [DailyRecord.RecordEntry(value: record.bmi, time: record.date)], weightValues: [DailyRecord.RecordEntry(value: WeightUnit.convert(record.weight, from: .kilograms, to: targetUnit), time: record.date)], weightUnit: targetUnit))
            }
        }
//        for record in dailyRecords {
//            print(record.date)
//        }
        return dailyRecords
    }
}
