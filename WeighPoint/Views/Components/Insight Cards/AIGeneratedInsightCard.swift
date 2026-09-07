//
//  AIGeneratedInsightCard.swift
//  WeighPoint
//
//  Created by Leo Zhou on 2/12/26.
//

import SwiftUI

struct AIGeneratedInsightCard: View {
    @State private var showingInfo = false
    @State private var showPlanExplanation = false
    let insight: AIGeneratedInsight
    var body: some View {
        CardView(padding: 32.0) {
            
            VStack(spacing: 16.0) {
                HStack {
                    Label("AI Insight", systemImage: "sparkle")
                        .foregroundStyle(.green.mix(with: .blue, by: 1.0))
                        .font(.callout)
                        .padding(8.0)
                        .background(RoundedRectangle(cornerRadius: 8.0, style: .continuous).foregroundStyle(.green.mix(with: .blue, by: 1.0).opacity(0.15)))
                        .offset(x: -8)
                    Spacer()
                    Button {
                        showingInfo = true
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.secondary)
                    }
                    .tint(.green.mix(with: .blue, by: 1.0))
                    .popover(isPresented: $showingInfo) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("About This Section")
                                .font(.headline)
                                .frame(width: 300, alignment: .leading)
                            Text("This section is AI generated, and can sometimes produce inaccurate information")
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.body)
                                .frame(width: 300, alignment: .leading)
                            Button {
                                showPlanExplanation = true
                            } label: {
                                Text("Learn more about how this section is generated")
                                    .multilineTextAlignment(.leading)
                            }                    .tint(.green.mix(with: .blue, by: 1.0))
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(width: 300, alignment: .leading)
                            
                        }
                        .padding()
                        // .frame(maxWidth: 300)
                        .presentationCompactAdaptation(.popover)
                    }
                    .sheet(isPresented: $showPlanExplanation) {
                        AIExplanationPage()
                    }
                }
                VStack(alignment: .leading, spacing: 16.0) {
                    Text(insight.textPair.headline)
                        .font(.title)
                        .fontWeight(.semibold)
                    // .frame(maxWidth: .infinity)
                    
                    Text(insight.textPair.insight)
                    // .font(.subheadline)
                    Divider()
                    Text("What to prioritize today")
                    //                        .font(.title3)
                    //                        .fontWeight(.semibold)
                        .font(.headline)
                    VStack(alignment: .leading, spacing: 8.0) {
                        ForEach(insight.textPair.actionItems, id: \.self) { actionItem in
                            HStack(spacing: 4.0) {
                                Text("•")
                                Text(actionItem)
                            }
                            .font(.subheadline)
                        }
                    }
                    
                    
                }
                // .padding([.horizontal, .bottom], 16.0)
                
            }
        }
        .transition(.blurReplace)
    }
}


#Preview {
    ZStack {
        MeshGradient(width: 3, height: 3, points: [
            .init(0, 0), .init(0.5, 0), .init(1, 0),
            .init(0, 0.5), .init(0.9, 0.3), .init(1, 0.5),
            .init(0, 1), .init(0.5, 1), .init(1, 1)
        ], colors: [
            .black, .black, .black,
            .blue, .blue, .blue,
            .green, .green, .green
        ])
        .ignoresSafeArea()
        ScrollView {
            AIGeneratedInsightCard(insight: .init(headline: "Sleep Like a Pro", insight: "Your lack of sleep last night resulted in the gaining of your weight", actionItems: ["Aim for 7 Hours of Sleep", "Drink more water"]))
                .padding()
        }
    }
}
