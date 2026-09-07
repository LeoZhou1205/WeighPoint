//
//  PlanExplanationPage.swift
//  WeighPoint
//
//  Created by Leo Zhou on 6/5/25.
//

import SwiftUI

struct PlanExplanationPage: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                Text("🔍 How Your Health Plan Is Generated")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("We believe in full transparency. Here’s exactly how your daily calorie targets and activity levels are computed — based on gold-standard health science used by registered dietitians and medical professionals worldwide.")
                
                Group {
                    Text("🧠 Step 1: Calculating Your BMR (Basal Metabolic Rate)")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("""
BMR is the number of calories your body needs at rest — just to keep you alive (breathing, circulating blood, etc.).

We use the Mifflin–St Jeor Equation:

• For men:
  BMR = 10 × weight (kg) + 6.25 × height (cm) – 5 × age + 5

• For women:
  BMR = 10 × weight (kg) + 6.25 × height (cm) – 5 × age – 161

• If you prefer not to specify gender:
  We skip the +5 or –161 adjustment.

• If you don’t enter your age:
  We assume a default of 30 years old.
""")
                    
                    Link("Source: Mifflin MD et al., *Am J Clin Nutr* (1990)", destination: URL(string: "https://pubmed.ncbi.nlm.nih.gov/2305711/")!)
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                
                Group {
                    Text("🏃 Step 2: Estimating Your TDEE (Total Daily Energy Expenditure)")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("""
We multiply your BMR by a physical activity level (PAL) based on your chosen strategy:

• Eat Less → Sedentary (×1.20)  
• Balanced → Moderately Active (×1.55)  
• Move More → Very Active (×1.725)  

This gives us your Total Daily Energy Expenditure (TDEE).
""")
                    
                    Link("Source: FAO/WHO/UNU Human Energy Requirements (2004)", destination: URL(string: "https://www.fao.org/3/y5686e/y5686e00.htm")!)
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                
                Group {
                    Text("🎯 Step 3: Building Your Calorie Plan")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("""
To help you reach your goal weight by your chosen date, we calculate how many calories you need to gain or lose.

We use a well-established estimate:  
1 kg of body fat ≈ 7,700 calories

We then divide this by the number of days to your goal to find your daily adjustment.
""")
                    
                    Link("Source: Wishnofsky M., *Am J Clin Nutr* (1958)", destination: URL(string: "https://pubmed.ncbi.nlm.nih.gov/13594878/")!)
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                
                Group {
                    Text("🏋️ Suggested Daily Exercise Burn")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("""
Based on your selected strategy, we estimate your exercise-related energy burn using:

• Eat Less → BMR × 0.20  
• Balanced → BMR × 0.55  
• Move More → BMR × 0.725  

These values are based on the same PAL system used in the TDEE calculation.
""")
                }
                
                Group {
                    Text("✅ Summary: Science You Can Trust")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("""
                Your health plan is built using reliable, evidence-based formulas — not guesswork. We use your personal data and combine it with medically accepted calculations to deliver a safe and effective path to your goals.
                
                🔐 **Your privacy matters.**  
                All calculations are done directly on your device. **We do not collect, store, or see any of your personal health data.** Everything stays local and private to you.
                
                Everything is backed by peer-reviewed research and health organization standards.
                
                Want to go deeper? You can explore the linked sources above or talk to a healthcare professional for tailored advice.
                """)
                }
                
            }
            .padding()
            .padding(.top)
        }
        .navigationTitle("How It Works")
    }
}

#Preview {
    PlanExplanationPage()
}
