//
//  AIExplanationPage.swift
//  WeighPoint
//
//  Created by Leo Zhou on 2/16/26.
//

import SwiftUI

struct AIExplanationPage: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Header
                Text("🤖 Understanding Your AI Insights")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("WeighPoint uses an intelligent analysis engine to help you understand the *context* behind your weight. It looks for patterns between your recovery, activity, and scale weight to differentiate between fat loss, water retention, and muscle repair.")
                
                // MARK: - The Inputs (Softened Rules)
                Group {
                    Text("📊 How It Connects the Dots")
                        .font(.headline)
                        .padding(.top)

                    Text("The engine analyzes the relationship between three key metrics to give you a clearer picture of your progress:")
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top) {
                            Image(systemName: "bed.double.fill")
                                .foregroundColor(.indigo)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Sleep & Recovery")
                                    .font(.subheadline).bold()
                                Text("The engine checks if your sleep duration is optimal for recovery or if it suggests a 'stress state.' Short sleep windows often spike stress hormones, leading to temporary water retention.")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Divider()
                        
                        HStack(alignment: .top) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Strain & Inflammation")
                                    .font(.subheadline).bold()
                                Text("It evaluates your workout intensity. High-strain days often cause micro-tears in muscle fiber. The body heals this by retaining fluid locally, which can cause the scale to go *up* despite fat loss.")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Divider()
                        
                        HStack(alignment: .top) {
                            Image(systemName: "chart.xyaxis.line")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Weight Trend")
                                    .font(.subheadline).bold()
                                Text("Rather than obsessing over today's specific number, the engine compares it to your recent history to identify spikes, drops, or plateaus.")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                }

                // MARK: - Limitations (The "No Flex" Section)
                Group {
                    Text("⚠️ Important Limitations")
                        .font(.headline)
                        .padding(.top)

                    Text("""
While our system uses advanced logic to interpret your data, it is an estimation tool, not a medical diagnosis.

• **We don't know everything:** We can't see what you ate (sodium intake), your hydration levels, or external life stress.
• **Every body is different:** Some people recover faster than others. The AI uses general physiological baselines that apply to most, but perhaps not all.
• **Data Quality:** The insight is only as good as the data entered. Missing sleep or workout logs may lead to generic advice.
""")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                
                // MARK: - Example
                Group {
                    Text("💡 Why This is Useful")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("The goal is to prevent panic. If your weight spikes +2lbs overnight, the AI can check your logs and help identify if it's likely just muscle fluid retention (inflammation) from yesterday's workout, rather than fat gain.")
                }

                // MARK: - Privacy
                Group {
                    Text("🔒 Privacy Matters")
                        .font(.headline)
                        .padding(.top)

                    Text("""
                Your insights are generated securely. To perform the analysis, the model provider receives only the necessary health data. Your personal identity—such as your name or email—is never shared. The analysis is performed to give you a specific daily insight and nothing else.
                """)
                    .font(.footnote)
                    .foregroundColor(.gray)
                }

            }
            .padding()
            .padding(.top)
        }
        .navigationTitle("How AI Works")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        AIExplanationPage()
    }
}
