//
//  BodyMetricsHistoryView.swift
//  WeighPoint
//
//  Created by Leo Zhou on 5/1/25.
//

import SwiftUI
import SwiftData
import Charts

struct MetricsHistoryCard: View {
    static var startOfSevenDaysAgo: Date = Calendar.current.startOfDay(for: .now).addingTimeInterval(-6 * 24 * 60 * 60)
    
    @Query(filter: #Predicate<BodyMetricsRecord> { record in
        record.date >= startOfSevenDaysAgo
    }, sort: \BodyMetricsRecord.date) private var records: [BodyMetricsRecord]
    
    private var dailyRecords: [DailyRecord] {
        DailyRecord.fromBodyMetricsRecords(records, targetUnit: weightUnit)
    }
    
    private var bmiRecordsDisplayRange: ClosedRange<Double> {
        let min = dailyRecords.min(by: { $0.minBMI < $1.minBMI })?.minBMI ?? 0
        let max = dailyRecords.max(by: { $0.maxBMI < $1.maxBMI })?.maxBMI ?? 0
        let buffer = 0.3 * (max - min)
        return (min - buffer)...(max + buffer)
    }
    
    private var weightRecordsDisplayRange: ClosedRange<Double> {
        let min = dailyRecords.min(by: { $0.minWeight < $1.minWeight })?.minWeight ?? 0
        let max = dailyRecords.max(by: { $0.maxWeight < $1.maxWeight })?.maxWeight ?? 0
        let buffer = 0.3 * (max - min)
        return (min - buffer)...(max + buffer)
    }
    
    @State private var selectedMetric: Metric = .bmi
    
    enum Metric: String, CaseIterable {
        case bmi = "BMI"
        case weight = "Weight"
        
        var localizedName: LocalizedStringResource {
            LocalizedStringResource(stringLiteral: rawValue)
        }
    }
    
    @AppStorage("preferredWeightUnit") private var weightUnit: WeightUnit = WeightUnit.systemDefault

    
    var body: some View {
        CardView {
            VStack {
                HStack(spacing: 16.0) {
                    Text("History")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Picker("Metric", selection: $selectedMetric.animation(.easeInOut)) {
                        ForEach(Metric.allCases, id: \.self) { metric in
                            Text(metric.localizedName).tag(metric)
                        }
                    }
                    .pickerStyle(.segmented)
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                
                Chart {
                    ForEach(dailyRecords) {
                        LineMark(x: .value("Date", $0.date, unit: .day), y: .value("Average", selectedMetric == .bmi ? $0.averageBMI : $0.averageWeight))
                            .interpolationMethod(.catmullRom)
                            .symbol(.circle)
                        AreaMark(x: .value("Date", $0.date, unit: .day), yStart: .value("Min", selectedMetric == .bmi ? $0.minBMI : $0.minWeight), yEnd: .value("Max", selectedMetric == .bmi ? $0.maxBMI : $0.maxWeight))
                            .interpolationMethod(.catmullRom)
                            .opacity(0.2)
                    }
                }
                .chartYScale(domain: selectedMetric == .bmi ? bmiRecordsDisplayRange : weightRecordsDisplayRange)
                .chartXVisibleDomain(length: 3600*7*24)
                .chartScrollPosition(x: .constant(Date.now))
                .chartXAxis(content: {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.weekday())
                    }
                })
                .frame(height: 150)
                .padding()
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    MetricsHistoryCard()
        .padding([.horizontal, .bottom])
        .modelContainer(MockDataStore.previewContainer())
}
