//
//  HomeView.swift
//  WeighPoint
//
//  Created by Leo Zhou on 5/1/25.
//

import SwiftUI
import SwiftData
import CloudStorage

extension View {
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil,from: nil, for: nil)
        }
    }
}

struct HomeView: View {
    //    @CloudStorage("birthYear") var userBirthYear: Int?
    //    @CloudStorage("gender") var gender: Gender?
    //    @CloudStorage("askForData") var askForData: Bool = true
    @CloudStorage("askForData") var askForData: Bool = true
    @CloudStorage("userGender") var gender: Gender = .preferNotToSay
    @CloudStorage("userBirthYear") var birthYear: Int?
    
    @State var height: String = ""
    @State var weight: String = ""
    @State var bmi: Double?
    @State var showLogSuccessfulIndicator: Bool = false
    @State private var showSetGoalView: Bool = false
    @Namespace private var namespace
        
    @Environment(\.modelContext) var modelContext
    
    @State var hkEngine = HealthKitEngine()
    @State var insightsEngine = InsightsEngine()
    
    @Query(sort: \BodyMetricsRecord.date) private var records: [BodyMetricsRecord]
    
    @Query private var goals: [WeightGoal]
    private var activeGoal: WeightGoal? {
        goals.first {
            $0.active
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                ScrollView {
                    VStack {
                        Spacer(minLength: 16)
                        BMICalculatorCard(height: $height, weight: $weight, bmi: $bmi, showLogSuccessfulIndicator: $showLogSuccessfulIndicator, insightsEngine: insightsEngine)
                            .padding([.horizontal, .bottom])
                        //                        BMIRangeIndicator(bmi: bmi)
                        //                            .padding([.horizontal, .bottom])
                        InsightsView(insights: insightsEngine.insights)
                            .padding(.bottom)
                        if insightsEngine.aiEnabld, let aiInsight = insightsEngine.aiInsight {
                            AIGeneratedInsightCard(insight: aiInsight)
                                .padding([.horizontal, .bottom])
                        }
                        if !records.isEmpty {
                            NavigationLink {
                                MetricsHistoryPage()
                                    .environment(insightsEngine)
                                    .environment(hkEngine)
                                    .navigationTransition(.zoom(sourceID: "history", in: namespace))
                                    
                            } label: {
                                MetricsHistoryCard()
                                    .padding([.horizontal, .bottom])
                                    .matchedTransitionSource(id: "history", in: namespace)
                            }
                            .tint(.primary)
                            .transition(.slide.animation(.spring))
                        }
                        
                    }
                }
                .navigationTitle("WeighPoint")
                .scrollIndicators(.hidden)
                .toolbar {
                    ToolbarItem {
                        Button {
                            showSetGoalView = true
                        } label: {
                            Label("My Goal", systemImage: "target")
                                .labelStyle(.titleOnly)
                        }
                        .sheet(isPresented: $showSetGoalView) {
                            SetGoalPage()
//                                .environment(\.modelContext, modelContext)
                        }
                    }
                }
                .hideKeyboardOnTap()
                .sheet(isPresented: $askForData) {
                    DataCollectionPage()
                }
                .sheet(isPresented: $insightsEngine.askForAI) {
                    EnableAIView()
                }
                .sheet(isPresented: $hkEngine.showPrimingSheet) {
                    HealthKitPermissionPrimingView()
                }
                .overlay {
                    if showLogSuccessfulIndicator {
                        if #available(iOS 26.0, *) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 48))
                                .frame(width: 200, height: 200)
                                .glassEffect(in: RoundedRectangle(cornerRadius: 32.0, style: .continuous))
                                .transition(.opacity.animation(.smooth))
                            
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 32.0, style: .continuous)
                                    .fill(.regularMaterial)
                                    .frame(width: 200, height: 200)
                                    .ignoresSafeArea()
                                Image(systemName: "checkmark")
                                    .font(.system(size: 48))
                                    .frame(width: 200, height: 200)
                            }
                            .transition(.opacity.animation(.smooth))
                        }
                        
                    }
                    
                }
                .sensoryFeedback(.success, trigger: showLogSuccessfulIndicator) { oldValue, newValue in
                    newValue
                }
            }
            .task {
                insightsEngine.initialize(with: modelContext)
                
                insightsEngine.reloadAllInsights()
                
                guard Locale.current.region?.identifier != "CN" else {
                    return
                }

                if !insightsEngine.aiPermissionAsked {
                    await insightsEngine.requestAccessForAI()
                }
                if !hkEngine.healthKitPermissionAsked  {
                    await hkEngine.requestAccess()
                }
                
                if insightsEngine.aiEnabld {
                    let sleepTime = await hkEngine.getSleepTime()
                    let activeEnergy = await hkEngine.getActiveEnergy()
                    let weightRecords = Array(records.suffix(5).map { ($0.weight, Double($0.date.timeIntervalSinceNow))})
                    await insightsEngine.loadAIInsight(weightRecords: weightRecords, sleepTime: sleepTime, activeEnergy: activeEnergy)
                }
            }
            .onChange(of: records) { _, _ in
                withAnimation {
                    insightsEngine.reloadAllInsights()
                }
            }
        }
        .environment(hkEngine)
        .environment(insightsEngine)
    }
}

#Preview {
    HomeView()
        .modelContainer(MockDataStore.previewContainer())
}
