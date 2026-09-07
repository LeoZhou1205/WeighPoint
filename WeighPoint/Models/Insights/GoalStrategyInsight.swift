//
//  GoalStrategyInsight.swift
//  WeighPoint
//
//  Created by Leo Zhou on 6/1/25.
//

import Foundation

struct GoalStrategyInsight: Insight {
    
    // Insight Specific Stuff
    
    var id: UUID = UUID()
    
    var title: LocalizedStringResource = "Today's Target"
    var icon: String = ""
    var message: LocalizedStringResource {
        if gender == .preferNotToSay || age == nil {
            return "This is based on rough estimates. For a more accurate result, consider providing your age and gender. Your data will be securely stored on your device or in iCloud."
        } else if (gender == .male && suggestedDailyCalorieIntake < 1500) || (gender == .female && suggestedDailyCalorieIntake < 1200) {
            return "Let’s make your goal healthier. Your current plan results in too few daily calories to safely support your body. Try a more gradual timeline for better, lasting results."
        } else {
            return "This is an evidence-based estimate, not a medical plan. For personalized advice, consult a healthcare professional."
        }
    }
    var priority: InsightPriority = .medium
    
    // Body Metrics
    var currentWeightInKg: Double
    var heightInCm: Double
    var age: Int?
    var gender: Gender
    
    // Target Specific
    var targetWeightInKg: Double
    var targetDate: Date
    var preferredStrategy: WeightGoal.PreferredStrategy
    
    //BMR
    var bmr: Double {
        let ageDecimal =  Double(age ?? 30)
        switch gender {
        case .male:
            return 10.0 * currentWeightInKg + 6.25 * heightInCm - 5.0 * ageDecimal + 5.0
        case .female:
            return 10.0 * currentWeightInKg + 6.25 * heightInCm - 5.0 * ageDecimal - 161.0
        case .preferNotToSay:
            return 10.0 * currentWeightInKg + 6.25 * heightInCm - 5.0 * ageDecimal
        }
    }
    
    //TDEE
    var tdee: Double {
        switch preferredStrategy {
        case .eatLess:
            // Assuming the user to be sedentary, i.e. a 1.2 multiplier
            return bmr * 1.2
        case .balanced:
            // Assuming the user to be moderately active, i.e. a 1.55 multiplier
            return bmr * 1.55
        case .moveMore:
            // Assuming the user to be very active, i.e. a 1.725 multiplier
            return bmr * 1.725
        }
    }
    
    // suggested daily intake
    var suggestedDailyCalorieIntake: Double {
        let weightChange = targetWeightInKg - currentWeightInKg
        let startOfTargetDate = Calendar.current.startOfDay(for: targetDate)
        let startOfToday = Calendar.current.startOfDay(for: .now)
        let daysToGoal = startOfTargetDate.timeIntervalSince(startOfToday) / (3600.0 * 24.0)
        let caloriesGapNeeded = weightChange * 7700 // roughly 7700kcal = 1kg of fat
        let dailyCaloriesGap = caloriesGapNeeded / daysToGoal
        let targetIntake = tdee + dailyCaloriesGap
        
        return targetIntake
    }
    
    // suggested daily exercise level
    var suggestedDailyExerciseLevel: Double {
        switch preferredStrategy {
        case .eatLess:
            // Assuming the user to be sedentary, i.e. a 1.2 multiplier
            return bmr * 0.2
        case .balanced:
            // Assuming the user to be moderately active, i.e. a 1.55 multiplier
            return bmr * 0.55
        case .moveMore:
            // Assuming the user to be very active, i.e. a 1.725 multiplier
            return bmr * 0.725
        }
    }
    
    
    static let kCalOf1Carrot: Double = 25
    static let kCalOf1BowlOfRice: Double = 210
    
    // https://www.nutritionix.com/food/rice-curry
    static let kCalOf1BowlOfCurryRice: Double = 297
    
    // https://www.nutritionix.com/food/caesar-salad
    static let kCalOf1PlateOfCaesarSalad: Double = 481
    
    // https://www.nutritionix.com/food/chicken-burrito
    static let kCalOf1ChickenBurrito: Double = 664
    
    static let metBasketabllShooting: Double = 4.5
    static let metJogging: Double = 8.0
    
    func hoursOf(met: Double) -> Double {
        return suggestedDailyExerciseLevel / currentWeightInKg / met
    }
}
