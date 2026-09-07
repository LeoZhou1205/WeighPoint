//
//  DataManagementView.swift
//  WeighPoint
//
//  Created by Leo Zhou on 5/31/25.
//

import SwiftUI
import SwiftData

struct DataManagementPage: View {
    enum SelectedDataType {
        case records
        case goals
        case personal
    }
    @Query(sort: \BodyMetricsRecord.date, order: .reverse) private var records: [BodyMetricsRecord]
    @Query(sort: \WeightGoal.dateSet, order: .reverse) private var weightGoals: [WeightGoal]
    
    @Environment(\.modelContext) private var modelContext
    @Environment(HealthKitEngine.self) var hkEngine
    @Environment(InsightsEngine.self) var insightsEngine
    
    @State private var selectedDataType: SelectedDataType = .records
    @State private var showPersonalData: Bool = false
    var body: some View {
        @Bindable var hkEngine = hkEngine
        @Bindable var insightsEngine = insightsEngine
        VStack(spacing: 16) {
            Picker("", selection: $selectedDataType) {
                Text("Records")
                    .tag(SelectedDataType.records)
                Text("Goals")
                    .tag(SelectedDataType.goals)
                Text("Personal")
                    .tag(SelectedDataType.personal)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            if selectedDataType == .personal {
                VStack(alignment: .leading) {
                    Button("Edit") {
                        
                        showPersonalData = true
                        
                    }
                    .buttonStyle(.bordered)
                    .sheet(isPresented: $showPersonalData) {
                        DataCollectionPage()
                    }
                    
                    Button("HealthKit Related") {
                        Task {
                            await hkEngine.manageAccess()
                        }
                    }
                    .buttonStyle(.bordered)
                    // .tint(.pink)
                    .sheet(isPresented: $hkEngine.showPrimingSheet) {
                        HealthKitPermissionPrimingView()
                    }
                    
                    Toggle("Enable AI", isOn: $insightsEngine.aiEnabld)
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.horizontal)
                    
                
            } else {
                List {
                    if selectedDataType == .records {
                        ForEach(records) { record in
                            HStack {
                                Text("BMI: \(record.bmi.formatted(.number.precision(.fractionLength(1))))")
                                Spacer()
                                Text(record.date.formatted())
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let recordToDelete = records[index]
                                modelContext.delete(recordToDelete)
                                try? modelContext.save()
                            }
                        }
                    } else if selectedDataType == .goals {
                        ForEach(weightGoals) { goal in
                            HStack {
                                Text("Goal: \(goal.targetWeightInKg.formatted(.number.precision(.fractionLength(1)))) kg by \(goal.targetDate.formatted(date: .abbreviated, time: .omitted))")
                                Spacer()
                                Text(goal.dateSet.formatted(date: .numeric, time: .omitted))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let goalToDelete = weightGoals[index]
                                modelContext.delete(goalToDelete)
                                try? modelContext.save()
                            }
                        }
                    }
                }
                .listStyle(.inset)
            }
            
        }
        .navigationTitle("My Data")
        
    }
}

#Preview {
    NavigationView {
        DataManagementPage()
    }
    .modelContainer(MockDataStore.previewContainer())
    .environment(InsightsEngine())
    .environment(HealthKitEngine())
}
