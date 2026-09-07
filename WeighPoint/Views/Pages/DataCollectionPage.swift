//
//  AppLaunchDataCollectionView.swift
//  WeighPoint
//
//  Created by Leo Zhou on 5/31/25.
//

import SwiftUI
import CloudStorage

struct DataCollectionPage: View {
    @Environment(InsightsEngine.self) var insightsEngine
    @State var temperaryGender: Gender = .preferNotToSay
    @CloudStorage("userGender") var gender: Gender = .preferNotToSay
    @CloudStorage("userBirthYear") var birthYear: Int?
    @State var age: String = ""
    var ageInt: Int? {
        Int(age)
    }
    @State var inputBlockHeight: CGFloat = 0.0
    @Environment(\.dismiss) var dismiss
    @FocusState var isAgeFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                Image("person1")
                    .resizable()
                // .scaledToFit()
                    .aspectRatio(contentMode: .fit)
                    .frame(minHeight: 50, maxHeight: 200)
                Text("Before we start, these details will help us create useful predictions.")
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding()
                
                HStack {
                    Text("Age")
                        .font(.headline)
                    Spacer()
                    TextField("age", text: $age)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .focused($isAgeFocused)
                }
                .padding()
                .overlay {
                    GeometryReader { proxy in
                        Color.clear.preference(key: InputBlockHeightPreferenceKey.self, value: proxy.size.height)
                    }
                    .onPreferenceChange(InputBlockHeightPreferenceKey.self) { newHeight in
                        inputBlockHeight = newHeight
                    }
                }
                .background(RoundedRectangle(cornerRadius: 16).fill(.thinMaterial))
                .padding(.horizontal)
                HStack {
                    Text("Gender")
                        .font(.headline)
                    Spacer()
                    
                    Picker("Gender", selection: $temperaryGender){
                        Text("Male").tag(Gender.male)
                        Text("Female").tag(Gender.female)
                        Text("Rather not say").tag(Gender.preferNotToSay)
                    }
                    
                }
                .padding(.horizontal)
                .frame(height: inputBlockHeight)
                .background(RoundedRectangle(cornerRadius: 16).fill(.thinMaterial))
                .padding([.horizontal, .top])
                .padding(.bottom, 32)
                Button {
                    gender = temperaryGender
                    if let ageInt = ageInt {
                        birthYear = Calendar.current.component(.year, from: .now) - ageInt
                    } else { birthYear = nil }
                    insightsEngine.reloadAllInsights()
                    dismiss()
                } label: {
                    Text("Done")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 16).fill(.accent)
                        }
                }
                .buttonStyle(.plain)
                .padding([.horizontal, .top])
            }
            .padding(.vertical)
            .frame(maxHeight: .infinity)
            //            .overlay(alignment: .bottomTrailing) {
            //                Text("* these fields are all optional")
            //                    .foregroundStyle(.secondary)
            //                    .padding()
            //                    .opacity(isAgeFocused ? 0.0 : 1.0)
            //            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Skip") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            temperaryGender = gender
            if let birthYear = birthYear {
                print("Hello")
                age = "\(Calendar.current.component(.year, from: .now) - birthYear)"
            }
        }
        .onChange(of: gender) { oldValue, newValue in
            temperaryGender = newValue
        }
        .onChange(of: birthYear) { oldValue, newValue in
            if let newValue = newValue {
                age = String(Calendar.current.component(.year, from: .now) - newValue)
            }
        }
    }
    
}

#Preview {
    DataCollectionPage()
        .environment(InsightsEngine())
}
