//
//  InsightsView.swift
//  WeighPoint
//
//  Created by Leo Zhou on 5/25/25.
//

import SwiftUI
import SwiftData

struct InsightsView: View {
    var insights: [any Insight]
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 32) {
                ForEach(insights, id: \.title.key) { insight in
                    if let insight = insight as? BMIInsight {
                        BMIInsightCard(insight: insight)
                            .containerRelativeFrame(.horizontal, count: 1, spacing: 16)
                    } else if let insight = insight as? PlanetWeightInsight {
                        PlanetWeightInsightCard(insight: insight)
                            .containerRelativeFrame(.horizontal, count: 1, spacing: 16)
                    } else if let insight = insight as? WeightChangeProgressInsight {
                        WeightChangeProgressInsightCard(insight: insight)
                            .containerRelativeFrame(.horizontal, count: 1, spacing: 16)
                    } else if let insight = insight as? GoalStrategyInsight {
                        GoalStrategyInsightCard(insight: insight)
                            .containerRelativeFrame(.horizontal, count: 1, spacing: 16)
                    } else if let insight = insight as? DefaultInsight {
                        DefaultInsightCard(insight: insight)
                            .containerRelativeFrame(.horizontal, count: 1, spacing: 16)
                    }
                    else {
                        Text("Unsupported Insight")
                    }
                }
            }
            .scrollTargetLayout()
            .overlay(alignment: .bottom) {
                PageIndicator()
            }
        }
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
        .scrollClipDisabled(true)
        .scrollIndicators(.hidden)
    }
}


struct InsightsViewPreviewView: View {
    @State var insightsEngine = InsightsEngine()
    @Environment(\.modelContext) var modelContext
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            ScrollView {
                InsightsView(insights: insightsEngine.insights)
                    .onAppear {
                        insightsEngine.reloadAllInsights()
                    }
            }
        }
        .onAppear {
            insightsEngine.initialize(with: modelContext)
            insightsEngine.reloadAllInsights()
        }
        
    }
}

#Preview {
    InsightsViewPreviewView()
        .modelContainer(MockDataStore.previewContainer())
}
