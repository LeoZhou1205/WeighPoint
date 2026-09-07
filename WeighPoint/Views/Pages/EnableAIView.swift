//
//  EnableAIView.swift
//  WeighPoint
//
//  Created by Leo Zhou on 2/15/26.
//
import SwiftUI

struct EnableAIView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(InsightsEngine.self) var insightsEngine
    var body: some View {
        NavigationStack {
            VStack {
                Image("rocket")
                    .resizable()
                // .scaledToFit()
                    .aspectRatio(contentMode: .fit)
                    .frame(minHeight: 50, maxHeight: 200)
                Text("Enable AI to get smarter and more personal advices")
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding()
                
//                HStack {
//                    Text("Our Privacy Policy")
//                        .font(.headline)
//                    Spacer()
//                    
//                    Button {
//                        
//                    } label: {
//                        Image(systemName: "link")
//                    }
//                    
//                }
//                .padding()
//                .background(RoundedRectangle(cornerRadius: 16).fill(.thinMaterial))
//                .padding([.horizontal])
                
                HStack {
                    Link(destination: URL(string: "https://imaginative-biscotti-f1a1f8.netlify.app")!) {
                        HStack {
                            Text("Review Our Privacy Policy")
                            Spacer()
                            Image(systemName: "link")
                        }
                    }
                    // .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(.thinMaterial))
                .padding([.horizontal, .top])
                .padding(.bottom, 32)
                
                Button {
                    insightsEngine.finishAuthorizationFlow(userSaysYes: true)
                } label: {
                    Text("Enable")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 16).fill(.accent)
                        }
                }
                .buttonStyle(.plain)
                .padding([.horizontal, .top])
                .padding(.bottom, 8)
                Text("AI features provided by Google Cloud AI")
                    .foregroundStyle(.secondary)
            }
            .toolbar {
                ToolbarItem {
                    Button("Skip") {
                        insightsEngine.finishAuthorizationFlow(userSaysYes: false)
                    }
                }
            }
        }
    }
}


#Preview {
    EnableAIView()
        .environment(InsightsEngine())
}
