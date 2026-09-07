//
//  BodyMetricsHistoryDetailsCardView.swift
//  WeighPoint
//
//  Created by Leo Zhou on 5/2/25.
//
import SwiftUI


struct MetricsHistoryDetailsCard: View {
    var record: DailyRecord
    var selectedMetric: MetricsHistoryPage.Metric
    var unit: WeightUnit
    var displayedAverage: String {
        if selectedMetric == .bmi {
            return record.averageBMI.formatted(.number.precision(.fractionLength(1)))
        } else {
            return record.averageWeight.formatted(.number.precision(.fractionLength(1)))
        }
    }
    var displayedMax: String {
        if selectedMetric == .bmi {
            return record.maxBMI.formatted(.number.precision(.fractionLength(1)))
        } else {
            return record.maxWeight.formatted(.number.precision(.fractionLength(1)))
        }
    }
    var displayedMaxTime: String {
        if selectedMetric == .bmi {
            return record.maxBMIRecordingTime.formatted(date: .omitted, time: .shortened)
        } else {
            return record.maxWeightRecordingTime.formatted(date: .omitted, time: .shortened)
        }
    }
    var displayedMin: String {
        if selectedMetric == .bmi {
            return record.minBMI.formatted(.number.precision(.fractionLength(1)))
        } else {
            return record.minWeight.formatted(.number.precision(.fractionLength(1)))
        }
    }
    var displayedMinTime: String {
        if selectedMetric == .bmi {
            return record.minBMIRecordingTime.formatted(date: .omitted, time: .shortened)
        } else {
            return record.minWeightRecordingTime.formatted(date: .omitted, time: .shortened)
        }
    }
    
    
    var body: some View {
        return CardView(cornerRadius: 16) {
            VStack(alignment: .leading) {
                Text(record.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                HStack {
                    VStack {
                        Grid(alignment: .leading, verticalSpacing: 16) {
                            GridRow {
                                Image(systemName: "list.dash")
                                    .font(.body)
                                Text(selectedMetric == .bmi ? "Average BMI" : "Average weight")
                                    .fontWeight(.medium)
                            }
                            GridRow {
                                Spacer()
                                    .frame(width: 0, height: 0)
                                HStack(alignment: .lastTextBaseline, spacing: 6) {
                                    Text(displayedAverage)
                                        .font(.title)
                                        .fontWeight(.semibold)
                                        .contentTransition(.numericText())
                                    if selectedMetric == .weight {
                                        Text(unit.rawValue)
                                            .font(.title3)
                                            .fontWeight(.medium)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                
                            }
                        }
                    }
                    Spacer()
                }
                
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(lineWidth: 1).foregroundStyle(.secondary))
                
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                    GridRow {
                        Image(systemName: "arrowtriangle.up.fill")
                            .foregroundStyle(.red)
                        Text("Max: \(displayedMax) \(selectedMetric == .bmi ? "" : unit.rawValue)")
                    }
                    GridRow {
                        Spacer()
                            .frame(width: 0, height: 0)
                        Label("\(displayedMaxTime)", systemImage: "clock")
                            .imageScale(.small)
                    }
                }
                .padding()
                
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                    GridRow {
                        Image(systemName: "arrowtriangle.down.fill")
                            .foregroundStyle(.green)
                        Text("Min: \(displayedMin) \(selectedMetric == .bmi ? "" : unit.rawValue)")
                    }
                    GridRow {
                        Spacer()
                            .frame(width: 0, height: 0)
                        Label("\(displayedMinTime)", systemImage: "clock")
                            .imageScale(.small)
                    }
                }
                .padding([.horizontal, .bottom])
                
            }
        }
        .drawingGroup()
        // .rotation3DEffect(Angle(degrees: selectedMetric == .bmi ? 0.0 : 360.0), axis: (x: 1, y: 0, z: 0))
        .animation(.bouncy(duration: 0.7), value: selectedMetric)
    }
}

#Preview {
    @Previewable @State var showBMI: Bool = false
    @Previewable @State var useMetric: Bool = true
    ZStack {
        Color(UIColor.systemGroupedBackground)
            .ignoresSafeArea()
        ScrollView {
            VStack {
                MetricsHistoryDetailsCard(record: DailyRecord(date: .now, bmiValues: [DailyRecord.RecordEntry(value: 23.0, time: .now), DailyRecord.RecordEntry(value: 25.0, time: .now)], weightValues: [DailyRecord.RecordEntry(value: 75.0, time: .now), DailyRecord.RecordEntry(value: 77.0, time: .now)], weightUnit: WeightUnit.pounds), selectedMetric: showBMI ? .bmi : .weight, unit: useMetric ? .kilograms : .pounds)
                Toggle("BMI?", isOn: $showBMI)
                Toggle("Metric?", isOn: $useMetric)
            }
            .padding()
        }
        
    }
}
