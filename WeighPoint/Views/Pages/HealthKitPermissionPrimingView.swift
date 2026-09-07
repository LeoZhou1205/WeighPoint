//
//  HealthKitPermissionPrimingView.swift
//  WeighPoint
//
//  Created by Leo Zhou on 2/14/26.
//
import SwiftUI
import HealthKitUI

struct HealthKitPermissionPrimingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(HealthKitEngine.self) private var hkEngine
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 32) {
                VStack(alignment: .leading, spacing: 32) {
                    Image("Icon - Apple Health")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(minHeight: 50, maxHeight: 90)
                        .shadow(color: .gray.opacity(0.3), radius: 16)
                    Text("Apple Health Integration")
                        .font(.title2).bold()
                    Text(description)
                        .foregroundStyle(.secondary)
                }
                
                Button(hkEngine.primingSheetButtonText) {
                    Task {
                        await hkEngine.finishAuthorizationFlow(userSaysYes: true)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.pink)
            
            }
            .padding()
            .toolbar {
                ToolbarItem {
                    Button("Skip") {
                        Task {
                            await hkEngine.finishAuthorizationFlow(userSaysYes: false)

                        }
                    }
                }
            }
        }
        
        
    }
    
    let description: LocalizedStringResource = """
        Connect to Apple Health so that we can use your sleep and workout records to tailor better weight management advices.
        
        Your data might be shared with a third party AI model provider
        """
}


#Preview {
    HealthKitPermissionPrimingView()
        .environment(HealthKitEngine())
}
