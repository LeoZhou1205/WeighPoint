//
//  MetricsHistoryPage.swift
//  WeighPoint
//
//  Created by Leo Zhou on 5/1/25.
//

import SwiftUI
import SwiftData
import Charts

struct MetricsHistoryPage: View {
    static var startOfSevenDaysAgo: Date = Calendar.current.startOfDay(for: .now).addingTimeInterval(-6 * 24 * 60 * 60)
    
    @Query(sort: \BodyMetricsRecord.date) private var records: [BodyMetricsRecord]
    
    private var dailyRecords: [DailyRecord] {
        DailyRecord.fromBodyMetricsRecords(records, targetUnit: weightUnit)
    }
    
    @Query private var goals: [WeightGoal]
    private var activeGoal: WeightGoal? {
        goals.first {
            $0.active
        }
    }
    
    private var bmiRecordsDisplayRange: ClosedRange<Double> {
        let min = dailyRecords.min(by: { $0.minBMI < $1.minBMI })?.minBMI ?? 0
        let max = dailyRecords.max(by: { $0.maxBMI < $1.maxBMI })?.maxBMI ?? 0
        let buffer = 0.3 * (max - min)
        return (min - buffer)...(max + buffer)
    }
    
    private var weightRecordsDisplayRange: ClosedRange<Double> {
        if showGoalLine {
            let minWithoutGoalLine = dailyRecords.min(by: { $0.minWeight < $1.minWeight })?.minWeight ?? 0
            let maxWithoutGoalLine = dailyRecords.max(by: { $0.maxWeight < $1.maxWeight })?.maxWeight ?? 0
            let goalLineValue: Double? = {
                if let activeGoal = activeGoal {
                    return WeightUnit.convert(activeGoal.targetWeightInKg, from: .kilograms, to: weightUnit)
                }
                return nil
            }()
            let min = min(minWithoutGoalLine, goalLineValue ?? .infinity)
            let max = max(maxWithoutGoalLine, goalLineValue ?? .zero)
            let buffer = 1.0 * (max - min)
            return (min - buffer)...(max + buffer)
        } else {
            let min = dailyRecords.min(by: { $0.minWeight < $1.minWeight })?.minWeight ?? 0
            let max = dailyRecords.max(by: { $0.maxWeight < $1.maxWeight })?.maxWeight ?? 0
            let buffer = 0.3 * (max - min)
            return (min - buffer)...(max + buffer)
        }
    }
    
    @State private var selectedMetric: Metric = .bmi
    @State private var currentlyViewedDate: Date = Calendar.current.startOfDay(for: .now)
    @State private var showDatePicker: Bool = false
    @State private var showGoalLine: Bool = false
    @AppStorage("preferredWeightUnit") private var weightUnit: WeightUnit = WeightUnit.systemDefault
    @Environment(\.modelContext) private var modelContext
    enum Metric: String, CaseIterable {
        case bmi = "BMI"
        case weight = "Weight"
        
        var localizedName: LocalizedStringResource {
            LocalizedStringResource(stringLiteral: rawValue)
        }
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    Picker("Metric", selection: $selectedMetric) {
                        ForEach(Metric.allCases, id: \.self) { metric in
                            Text(metric.localizedName).tag(metric)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal)
                    //                    if selectedMetric == .weight && activeGoal != nil {
                    //                        CardView(padding: 0) {
                    //
                    //                        }
                    //                        .padding([.horizontal, .top])
                    //                    }
                    CardView(padding: 0, cornerRadius: 16.0) {
                        VStack(spacing: 0) {
                            if selectedMetric == .weight && activeGoal != nil {
                                HStack {
                                    Toggle("Goal Line", isOn: $showGoalLine)
                                }
                                // .padding([.top, .horizontal])
                                .padding(12)
                                Divider()
                            }
                            
                            chartPart
                                .animation(.spring(), value: showGoalLine)
                        }
                        
                    }
                    .padding()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 8) {
                            ForEach(dailyRecords, id: \.date) { record in
                                MetricsHistoryDetailsCard(record: record, selectedMetric: selectedMetric, unit: weightUnit)
                                    .containerRelativeFrame(.horizontal, count: 1, spacing: 16)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .contentMargins(.horizontal, 16, for: .scrollContent)
                    
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: Binding($currentlyViewedDate), anchor: .trailing)
                    .animation(.easeInOut, value: currentlyViewedDate)
                    
                    NavigationLink {
                        DataManagementPage()
                    } label: {
                        CardView(cornerRadius: 16.0) {
                            HStack {
                                Text("Manage my data")
                                Spacer()
                                Image(systemName: "chevron.forward")
                                
                            }
                        }
                        
                    }
                    .padding()
                }
                .navigationTitle("History")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showDatePicker = true
                        } label: {
                            Label("Select date", systemImage: "calendar")
                        }
                        .popover(isPresented: $showDatePicker) {
                            DatePicker("Pick Date", selection: $currentlyViewedDate, in: Date.distantPast...Date.now, displayedComponents: [.date])
                                .datePickerStyle(.graphical)
                            // .fixedSize(horizontal: true, vertical: true)
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 300)
                            
                                .padding()
                                .presentationCompactAdaptation(.popover)
                        }
                        
                    }
                }
                .animation(.bouncy, value: selectedMetric)
            }
        }
        
    }
    
    var chartPart: some View {
        let targetWeightInKg = activeGoal?.targetWeightInKg
        return Chart {
            ForEach(dailyRecords, id: \.date) {
                LineMark(x: .value("Date", $0.date, unit: .day), y: .value("Average", selectedMetric == .bmi ? $0.averageBMI : $0.averageWeight))
                    .interpolationMethod(.catmullRom)
                    .symbol(.circle)
                    .symbolSize(currentlyViewedDate == $0.date ? 64 : 32)
//                AreaMark(x: .value("Date", $0.date, unit: .day), yStart: .value("Min", selectedMetric == .bmi ? $0.minBMI : $0.minWeight), yEnd: .value("Max", selectedMetric == .bmi ? $0.maxBMI : $0.maxWeight))
//                    .interpolationMethod(.catmullRom)
//                    .opacity(0.2)
                
                if showGoalLine {
                    RuleMark(y: .value("Target", WeightUnit.convert(targetWeightInKg ?? 0.0, from: .kilograms, to: weightUnit)))
                        .lineStyle(StrokeStyle(lineWidth: 1.0, lineCap: .round, dash: [10.0], dashPhase: 5.0))
                }
                
            }
        }
        .chartYScale(domain: selectedMetric == .bmi ? bmiRecordsDisplayRange : weightRecordsDisplayRange)
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: 3600*7*24)
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 3)) {
                AxisValueLabel()
            }
            AxisMarks {
                AxisGridLine()
            }
        }
        .modifier(ScrollModifier(scrollPosition: currentlyViewedDate))
        .animation(.easeInOut, value: currentlyViewedDate)
        .frame(height: 150)
        .padding()
        .onChange(of: currentlyViewedDate) { old, new in
            print("\(old.formatted()) -> \(new.formatted())")
        }
    }
}



#Preview {
    NavigationStack {
        MetricsHistoryPage()
            .modelContainer(MockDataStore.previewContainer())
    }
}


struct ScrollModifier: ViewModifier, Animatable {
    var scrollPosition: Date
    
    var animatableData: Double {
        // here I convert between Double and Date, because Date doesn't conform to VectorArithmetic
        // if the x axis values already conform to VectorArithmetic, you don't need to do any conversion
        get { scrollPosition.timeIntervalSince1970 }
        set { scrollPosition = Date(timeIntervalSince1970: newValue) }
    }
    
    func body(content: Content) -> some View {
        content.chartScrollPosition(x: .constant(scrollPosition))
    }
}
