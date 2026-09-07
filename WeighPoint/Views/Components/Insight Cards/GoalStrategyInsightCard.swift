//
//  GoalStrategyInsightCard.swift
//  WeighPoint
//
//  Created by Leo Zhou on 6/1/25.
//

import SwiftUI

struct GoalStrategyInsightCard: View {
    var insight: GoalStrategyInsight
    @State var showingInfo: Bool = false
    @State var showPlanExplanation: Bool = false
    var body: some View {
        CardView(padding: 32) {
            VStack(spacing: 0) {
                Text(insight.title)
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .trailing) {
                        Button {
                            showingInfo = true
                        } label: {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.secondary)
                        }
                        .popover(isPresented: $showingInfo) {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("About This Plan")
                                    .font(.headline)
                                    .frame(width: 300, alignment: .leading)
                                Text(insight.message)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .font(.body)
                                    .frame(width: 300, alignment: .leading)
                                Button {
                                    showPlanExplanation = true
                                } label: {
                                    Text("Learn more about how this plan is generated")
                                        .multilineTextAlignment(.leading)
                                }
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(width: 300, alignment: .leading)

                            }
                            .padding()
                            // .frame(maxWidth: 300)
                            .presentationCompactAdaptation(.popover)
                        }
                        .sheet(isPresented: $showPlanExplanation) {
                            PlanExplanationPage()
                        }
                    }
                VStack(spacing: 16) {
                    VStack {
                        
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Text("Intake: ")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("\(insight.suggestedDailyCalorieIntake.formatted(.number.precision(.fractionLength(0)))) kcal")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.accent)
                        }
                        Text("E.g. \(Int((insight.suggestedDailyCalorieIntake / GoalStrategyInsight.kCalOf1PlateOfCaesarSalad).rounded())) plate(s) of Caesar Salad or \(Int((insight.suggestedDailyCalorieIntake / GoalStrategyInsight.kCalOf1ChickenBurrito).rounded())) chicken burrito(s)")
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .font(.headline)
                            .fontWeight(.regular)
                    }
                    .frame(maxHeight: .infinity)
                    VStack {
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Text("Exercise: ")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("\(insight.suggestedDailyExerciseLevel.formatted(.number.precision(.fractionLength(0)))) kcal")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.accent)
                        }
                        Text("E.g. \(insight.hoursOf(met: GoalStrategyInsight.metJogging).formatted(.number.precision(.fractionLength(1)))) hours of jogging, or whichever sport you love")
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .font(.headline)
                            .fontWeight(.regular)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top)
                
                
                
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom)
            
        }
    }
    
    //    var meshGradient: some View {
    //        MeshGradient(width: 3, height: 3, points: [[0.0, 0.0], [0.5, 0.0], [1.0, 0.0], [0.0, 0.5], [0.5, 0.5], [1.0, 0.5], [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]], colors: [.green, .accent, .green, .teal, Color(.systemBackground), .cyan, .blue, .cyan, .green])
    //    }
}

#Preview {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        ScrollView {
            GoalStrategyInsightCard(insight: .init(currentWeightInKg: 82, heightInCm: 180, age: 17, gender: .male, targetWeightInKg: 75, targetDate: Calendar.current.date(byAdding: .day, value: 60, to: .now) ?? .now, preferredStrategy: .balanced))
                .padding()
        }
    }
    
}
