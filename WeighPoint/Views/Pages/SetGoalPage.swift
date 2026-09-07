//
//  SetGoalView.swift
//  WeighPoint
//
//  Created by Leo Zhou on 5/10/25.
//

import SwiftUI
import SwiftData

struct SetGoalPage: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(InsightsEngine.self) var insightsEngine
    
    private static var latestRecordFetchDescriptor: FetchDescriptor<BodyMetricsRecord> {
        var descriptor = FetchDescriptor<BodyMetricsRecord>(sortBy: [SortDescriptor(\BodyMetricsRecord.date, order: .reverse)])
        descriptor.fetchLimit = 1 // Set the fetch limit on the descriptor itself
        return descriptor
    }
    @Query(latestRecordFetchDescriptor) private var latestRecords: [BodyMetricsRecord]
    private var newestHeight: Double? {
        latestRecords.first?.height
    }
    
    @Query private var goals: [WeightGoal]
    private var activeGoal: WeightGoal? {
        goals.first {
            $0.active
        }
    }
    
    @Environment(\.dismiss) private var dismiss
    @State private var targetWeight: String = ""
    private var targetWeightInKg: Double? {
        if let targetWeightDouble = Double(targetWeight) {
            return weightUnit == .kilograms ? targetWeightDouble : WeightUnit.convert(targetWeightDouble, from: .pounds, to: .kilograms)
        }
        return nil
    }
    @State private var targetReachingDate: Date = (Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now)
    
    @State private var preferredStrategy: WeightGoal.PreferredStrategy = .balanced
    
    @State private var showInputInvalidAlert: Bool = false
    
    @State private var showPlanExplanation: Bool = false
    
    @AppStorage("preferredWeightUnit") private var weightUnit: WeightUnit = WeightUnit.systemDefault
    
    @State private var inputBlockHeight: CGFloat = 0.0
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Image("person2")
                    .resizable()
                // .scaledToFit()
                    .aspectRatio(contentMode: .fit)
                    .frame(minHeight: 50, maxHeight: 200)
                Text(activeGoal == nil ? "Let’s define your goal and help you with daily food and activity tips." : "You can edit your goal to fine-tune your daily food and activity tips.")
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding()
                VStack {
                    HStack {
                        Text("Target Weight")
                            .font(.headline)
                        Spacer()
                        TextField("e.g. \(weightUnit == .pounds ? 130 : 60)", text: $targetWeight)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                        Menu {
                            ForEach(Array(WeightUnit.allCases), id: \.self) { unit in
                                Button(unit.rawValue) {
                                    withAnimation {
                                        weightUnit = unit
                                    }
                                }
                            }
                        } label: {
                            Text(weightUnit.rawValue)
                                .frame(width: 25)
                        }
                        .tint(.secondary)
                        //                .menuStyle(.button)
                        //                .buttonStyle(.bordered)
                        //                .accentColor(.secondary)
                    }
                }
                
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(.thinMaterial))
                .overlay {
                    Text("Test")
                        .opacity(0.0)
                        .padding()
                        .overlay {
                            GeometryReader { proxy in
                                Color.clear.preference(key: InputBlockHeightPreferenceKey.self, value: proxy.size.height)
                            }
                            .onPreferenceChange(InputBlockHeightPreferenceKey.self) { newHeight in
                                inputBlockHeight = newHeight
                            }
                        }
                }
                .padding(.horizontal)
                
                DatePicker(selection: $targetReachingDate, in: Date.now...Date.distantFuture, displayedComponents: [.date]) {
                    Text("Reach by")
                        .font(.headline)
                }
                
                // .padding()
                .padding(.horizontal)
                .frame(height: inputBlockHeight)
                .background(RoundedRectangle(cornerRadius: 16).fill(.thinMaterial))
                .padding([.horizontal, .top])
                
                HStack {
                    Text("Preferred Strategy")
                        .font(.headline)
                    Spacer()
                    Picker("Preferred Strategy", selection: $preferredStrategy) {
                        ForEach(Array(WeightGoal.PreferredStrategy.allCases), id: \.self) { strategy in
                            Text(strategy.localizedStringKey).tag(strategy)
                        }
                    }
                    //                .menuStyle(.button)
                    //                .buttonStyle(.bordered)
                    //                .accentColor(.secondary)
                }
                .padding(.horizontal)
                .frame(height: inputBlockHeight)
                .background(RoundedRectangle(cornerRadius: 16).fill(.thinMaterial))
                .padding([.top, .horizontal])
                Button {
                    showPlanExplanation = true
                } label: {
                    Text("Learn more about how we create your plan")
                }
                .padding()
                .sheet(isPresented: $showPlanExplanation) {
                    PlanExplanationPage()
                }
                Button {
                    if activeGoal == nil {
                        if let targetWeightInKg = targetWeightInKg {
                            modelContext.insert(WeightGoal(targetWeightInKg: targetWeightInKg, targetDate: targetReachingDate, dateSet: .now, preferredStrategy: preferredStrategy))
                            do {
                                try modelContext.save()
                            } catch {
                                //                                    print("Cannot save model context, \(error)")
                                fatalError("Cannot save model context, \(error)")
                            }
                            
                            insightsEngine.reloadAllInsights()
                            dismiss()
                            
                        } else {
                            showInputInvalidAlert = true
                        }
                    } else {
                        if let targetWeightInKg = targetWeightInKg {
                            
                            activeGoal?.targetWeightInKg = targetWeightInKg
                            activeGoal?.targetDate = targetReachingDate
                            activeGoal?.preferredStrategy = preferredStrategy
                            
                            try? modelContext.save()
                            insightsEngine.reloadAllInsights()
                            dismiss()
                        } else {
                            showInputInvalidAlert = true
                        }
                    }
                    
                    
                } label: {
                    Text("Done")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 16).fill(.accent)
                        }
                }
                .buttonStyle(.plain)
                .padding([.horizontal, .top])
                
            }
            .padding(.vertical)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            
        }
        .onAppear {
            if let activeGoal = activeGoal {
                targetWeight = WeightUnit.convert(activeGoal.targetWeightInKg, from: .kilograms, to: weightUnit).formatted(.number.precision(.fractionLength(1)))
                targetReachingDate = activeGoal.targetDate
                preferredStrategy = activeGoal.preferredStrategy
            }
        }
        // .hideKeyboardOnTap()
    }
}

#Preview {
    SetGoalPage()
        .modelContainer(MockDataStore.previewContainer())
        .environment(InsightsEngine())
    
}



struct InputBlockHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat  = 0.0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
    
    typealias Value = CGFloat
    
    
}
