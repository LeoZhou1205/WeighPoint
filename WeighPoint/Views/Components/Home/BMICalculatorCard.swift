//
//  BMICalculatorCard.swift
//  WeighPoint
//
//  Created by Leo Zhou on 5/1/25.
//

import SwiftUI
import SwiftData


struct BMICalculatorCard: View {
    
    
    private static var latestRecordFetchDescriptor: FetchDescriptor<BodyMetricsRecord> {
        var descriptor = FetchDescriptor<BodyMetricsRecord>(sortBy: [SortDescriptor(\BodyMetricsRecord.date, order: .reverse)])
        descriptor.fetchLimit = 1 // Set the fetch limit on the descriptor itself
        return descriptor
    }
    @Query(latestRecordFetchDescriptor) private var latestRecords: [BodyMetricsRecord]
    private var newestHeight: Double? {
        return latestRecords.first?.height
    }
    
    
    @Binding var height: String
    @Binding var weight: String
    @Binding var bmi: Double?
    @Binding var showLogSuccessfulIndicator: Bool
    @State var showInputInvalidAlert: Bool = false
    @AppStorage("preferredHeightUnit") private var heightUnit: HeightUnit = HeightUnit.systemDefault
    @AppStorage("preferredWeightUnit") private var weightUnit: WeightUnit = WeightUnit.systemDefault
    @State private var selectedFeet: Int = 4
    @State private var selectedInches: Int = 0
    @Environment(\.modelContext) private var modelContext
    
    var insightsEngine: InsightsEngine
    
    
    @Query private var goals: [WeightGoal]
    private var activeGoal: WeightGoal? {
        goals.first {
            $0.active
        }
    }
    
    private var heightDouble: Double? {
        if heightUnit == .inches {
            return Double(selectedFeet * 12 + selectedInches)
        }
        return Double(height)
    }
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16.0) {
                CustomTextField(
                    placeholder: "Your height",
                    title: "Height",
                    selectedUnit: $heightUnit,
                    text: $height,
                    selectedFeet: $selectedFeet,
                    selectedInches: $selectedInches
                )
                CustomTextField(placeholder: "Your weight", title: "Weight", selectedUnit: $weightUnit, text: $weight, chipText: activeGoal == nil ? nil : "Goal \(WeightUnit.convert(activeGoal!.targetWeightInKg, from: .kilograms, to: weightUnit).formatted(.number.precision(.significantDigits(3))))\(weightUnit.rawValue)")
                
                HStack(spacing: 16.0) {
                    Button {
                        if let heightValue = heightDouble,
                           let weight = Double(weight) {
                            guard weight > 0 && heightValue > 0 else {
                                showInputInvalidAlert = true
                                return
                            }
                            let heightInCm = heightUnit.convert(heightValue, to: .centimeters)
                            let weightInKg = weightUnit.convert(weight, to: .kilograms)
                            bmi = weightInKg / pow(heightInCm / 100.0, 2)
                            
                            if let bmi = bmi {
                                withAnimation {
                                    insightsEngine.reloadBMIRelatedInsights(bmi: bmi)
                                }
                            }
                        } else {
                            showInputInvalidAlert = true
                        }
                    } label: {
                        Label("Calculate BMI", systemImage: "plusminus")
                            .foregroundStyle(.white)
                            .labelStyle(.titleOnly)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.accent))
                    }
                    .alert("Input not valid", isPresented: $showInputInvalidAlert) {
                        Button("OK", role: .cancel) {}
                    }
                    
                    Button {
                        if let heightValue = heightDouble,
                           let weight = Double(weight) {
                            let heightInCm = heightUnit.convert(heightValue, to: .centimeters)
                            let weightInKg = weightUnit.convert(weight, to: .kilograms)
                            let record = BodyMetricsRecord(date: Date(), weight: weightInKg, height: heightInCm)
                            modelContext.insert(record)
                            do {
                                try modelContext.save()
                                showLogSuccessfulIndicator = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showLogSuccessfulIndicator = false
                                }
                            } catch {
                                
                            }
                        } else {
                            showInputInvalidAlert = true
                        }
                    } label: {
                        Label("Log", systemImage: "bookmark")
                            .labelStyle(.titleAndIcon)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.ultraThinMaterial).stroke(.thinMaterial))
                    }
                    .tint(.primary)
                }
            }
        }
        // .padding([.horizontal, .bottom])
        .onAppear {
            
            if let newestHeight = newestHeight {
                height = "\(newestHeight.formatted(.number.precision(.fractionLength(1))))"
                print(height)
                if let height = Double(height) {
                    let heightInInches = HeightUnit.convert(height, from: .centimeters, to: .inches)
                    let heightInFeet = Int(floor(heightInInches / 12))
                    let heightInInchesInt = Int((heightInInches - Double(12 * heightInFeet)).rounded())
                    selectedFeet = heightInFeet
                    selectedInches = heightInInchesInt
                }
            }
        }
    }
}

struct CustomTextField<T: Unit & CaseIterable>: View {
    var placeholder: LocalizedStringKey
    var title: LocalizedStringResource
    @Binding var selectedUnit: T
    @Binding var text: String
    var selectedFeet: Binding<Int>? = nil
    var selectedInches: Binding<Int>? = nil
    
    var chipText: LocalizedStringResource?
    
    private var isImperial: Bool {
        selectedUnit.rawValue == "ft"
    }
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
            if let chipText = chipText {
                Text(chipText)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.accent)
                    .padding(6)
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(.accent.opacity(0.1)))
            }
            if isImperial && selectedFeet != nil && selectedInches != nil {
                Spacer()
                HStack(spacing: 0) {
                    Picker("Feet", selection: selectedFeet!) {
                        ForEach(2...7, id: \.self) { feet in
                            Text("\(feet)").tag(feet)
                        }
                    }
                    .tint(.primary)
                    .frame(width: 50)
                    .clipped()
                    Text("'")
                    
                    Picker("Inches", selection: selectedInches!) {
                        ForEach(0...11, id: \.self) { inch in
                            Text("\(inch)").tag(inch)
                        }
                    }
                    .tint(.primary)
                    
                    .frame(width: 60)
                    .clipped()
                    Text("\"")
                }
            } else {
                TextField(placeholder, text: $text)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
            }
            Menu {
                ForEach(Array(T.allCases), id: \.self) { unit in
                    Button(unit.rawValue) {
                        handleUnitChange(to: unit)
                    }
                }
            } label: {
                Text(selectedUnit.rawValue)
                    .frame(width: 25)
            }
            .menuStyle(.button)
            .accentColor(.secondary)
        }
        .padding(.leading)
        .padding(.trailing, 8)
        .frame(height: 40)
        .background {
            RoundedRectangle(cornerRadius: 16.0, style: .continuous)
                .fill(.ultraThinMaterial)
                .stroke(.thinMaterial)
        }
    }
    
    private func handleUnitChange(to newUnit: T) {
        //        if title == "Height" {
        //            if selectedUnit.rawValue == "cm" && newUnit.rawValue == "ft" {
        //                if let cm = Double(text) {
        //                    let totalInches = cm / 2.54
        //                    selectedFeet?.wrappedValue = Int(totalInches / 12)
        //                    selectedInches?.wrappedValue = Int(totalInches.truncatingRemainder(dividingBy: 12))
        //                }
        //            } else if selectedUnit.rawValue == "ft" && newUnit.rawValue == "cm" {
        //                let feet = selectedFeet?.wrappedValue ?? 0
        //                let inches = selectedInches?.wrappedValue ?? 0
        //                let totalInches = Double(feet * 12 + inches)
        //                let cm = totalInches * 2.54
        //                text = String(format: "%.1f", cm)
        //            }
        //        } else {
        //            // For non-height fields (e.g. weight)
        //            if let value = Double(text) {
        //                let converted = selectedUnit.convert(value, to: newUnit)
        //                text = String(format: "%.1f", converted)
        //            }
        //        }
        selectedUnit = newUnit
    }
}

#Preview {
    @Previewable @State var height: String = ""
    @Previewable @State var weight: String = ""
    @Previewable @State var bmi: Double?
    
    ScrollView {
        BMICalculatorCard(height: $height, weight: $weight, bmi: $bmi, showLogSuccessfulIndicator: .constant(false), insightsEngine: InsightsEngine())
            .modelContainer(MockDataStore.previewContainer())
    }
    
}
