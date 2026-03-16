// Copyright 2026 Marcus Neves
// SPDX-License-Identifier: Apache-2.0

import Foundation
import HealthKit

enum HealthDataCategory: String, CaseIterable, Codable, Sendable {
    case activity
    case vitals
    case nutrition
    case sleep
    case body
    case symptoms
    case events
    case reproductive
    case hearing
    case environment
    case selfCare
    case stateOfMind
}

enum HealthDataType: String, CaseIterable, Codable, Sendable, Identifiable {

    // MARK: - Activity
    case steps
    case distanceWalkingRunning
    case distanceCycling
    case activeEnergyBurned
    case basalEnergyBurned
    case exerciseTime
    case standHours
    case flightsClimbed
    case workouts
    case runningSpeed
    case runningPower
    case runningStrideLength
    case runningGroundContactTime
    case runningVerticalOscillation
    case cyclingCadence
    case cyclingPower
    case cyclingFunctionalThresholdPower
    case cyclingSpeed
    case swimmingStrokeCount
    case distanceSwimming
    case distanceWheelchair
    case pushCount
    case distanceDownhillSnowSports
    case distanceCrossCountrySkiing
    case crossCountrySkiingSpeed
    case distancePaddleSports
    case paddleSportsSpeed
    case distanceRowing
    case rowingSpeed
    case distanceSkatingSports
    case appleMoveTime
    case estimatedWorkoutEffortScore
    case workoutEffortScore
    case physicalEffort

    // MARK: - Mobility (activity subcategory)
    case appleWalkingSteadiness
    case sixMinuteWalkTestDistance
    case walkingSpeed
    case walkingStepLength
    case walkingAsymmetryPercentage
    case walkingDoubleSupportPercentage
    case stairAscentSpeed
    case stairDescentSpeed

    // MARK: - Vitals
    case heartRate
    case restingHeartRate
    case walkingHeartRateAverage
    case heartRateVariability
    case bloodPressureSystolic
    case bloodPressureDiastolic
    case bloodOxygen
    case respiratoryRate
    case bodyTemperature
    case vo2Max
    case heartRateRecoveryOneMinute
    case atrialFibrillationBurden
    case bloodGlucose
    case insulinDelivery
    case inhalerUsage
    case numberOfTimesFallen
    case electrodermalActivity
    case forcedExpiratoryVolume1
    case forcedVitalCapacity
    case peakExpiratoryFlowRate
    case peripheralPerfusionIndex
    case bloodAlcoholContent
    case numberOfAlcoholicBeverages

    // MARK: - Sleep
    case sleepAnalysis
    case sleepInBed
    case sleepAsleep
    case sleepAwake
    case sleepREM
    case sleepCore
    case sleepDeep
    case appleSleepingWristTemperature
    case appleSleepingBreathingDisturbances

    // MARK: - Body
    case weight
    case height
    case bodyMassIndex
    case bodyFatPercentage
    case leanBodyMass
    case waistCircumference
    case basalBodyTemperature

    // MARK: - Environment
    case timeInDaylight
    case uvExposure
    case underwaterDepth
    case waterTemperature

    // MARK: - Hearing
    case environmentalAudioExposure
    case headphoneAudioExposure
    case environmentalSoundReduction

    // MARK: - Nutrition
    case dietaryEnergyConsumed
    case dietaryProtein
    case dietaryCarbohydrates
    case dietaryFatTotal
    case dietaryFatSaturated
    case dietaryFatMonounsaturated
    case dietaryFatPolyunsaturated
    case dietaryFiber
    case dietarySugar
    case dietarySodium
    case dietaryPotassium
    case dietaryCalcium
    case dietaryPhosphorus
    case dietaryMagnesium
    case dietaryIron
    case dietaryZinc
    case dietarySelenium
    case dietaryChloride
    case dietaryChromium
    case dietaryCopper
    case dietaryIodine
    case dietaryMolybdenum
    case dietaryManganese
    case dietaryNiacin
    case dietaryRiboflavin
    case dietaryThiamin
    case dietaryPantothenicAcid
    case dietaryBiotin
    case dietaryFolate
    case dietaryVitaminA
    case dietaryVitaminB6
    case dietaryVitaminB12
    case dietaryVitaminC
    case dietaryVitaminD
    case dietaryVitaminE
    case dietaryVitaminK
    case dietaryCaffeine
    case dietaryWater
    case dietaryCholesterol

    // MARK: - Symptoms
    case abdominalCramps
    case bloating
    case constipation
    case diarrhea
    case heartburn
    case nausea
    case vomiting
    case appetiteChanges
    case chills
    case dizziness
    case fainting
    case fatigue
    case fever
    case generalizedBodyAche
    case hotFlashes
    case chestTightnessOrPain
    case coughing
    case rapidPoundingOrFlutteringHeartbeat
    case shortnessOfBreath
    case skippedHeartbeat
    case wheezing
    case lowerBackPain
    case headache
    case memoryLapse
    case moodChanges
    case lossOfSmell
    case lossOfTaste
    case runnyNose
    case soreThroat
    case sinusCongestion
    case breastPain
    case pelvicPain
    case vaginalDryness
    case acne
    case drySkin
    case hairLoss
    case nightSweats
    case sleepChanges
    case bladderIncontinence

    // MARK: - Events
    case lowHeartRateEvent
    case highHeartRateEvent
    case irregularHeartRhythmEvent
    case appleStandHour
    case appleWalkingSteadinessEvent
    case lowCardioFitnessEvent
    case environmentalAudioExposureEvent
    case headphoneAudioExposureEvent

    // MARK: - Reproductive
    case menstrualFlow
    case intermenstrualBleeding
    case infrequentMenstrualCycles
    case irregularMenstrualCycles
    case persistentIntermenstrualBleeding
    case prolongedMenstrualPeriods
    case cervicalMucusQuality
    case ovulationTestResult
    case progesteroneTestResult
    case sexualActivity
    case contraceptive
    case pregnancy
    case pregnancyTestResult
    case lactation

    // MARK: - Self Care
    case toothbrushingEvent
    case handwashingEvent

    // MARK: - State of Mind
    case stateOfMind

    // MARK: - Identifiable
    var id: String { rawValue }

    // MARK: - Category
    var category: HealthDataCategory {
        switch self {
        case .steps, .distanceWalkingRunning, .distanceCycling, .activeEnergyBurned, .basalEnergyBurned,
             .exerciseTime, .standHours, .flightsClimbed, .workouts,
             .runningSpeed, .runningPower, .runningStrideLength, .runningGroundContactTime, .runningVerticalOscillation,
             .cyclingCadence, .cyclingPower, .cyclingFunctionalThresholdPower, .cyclingSpeed,
             .swimmingStrokeCount, .distanceSwimming,
             .distanceWheelchair, .pushCount,
             .distanceDownhillSnowSports, .distanceCrossCountrySkiing, .crossCountrySkiingSpeed,
             .distancePaddleSports, .paddleSportsSpeed,
             .distanceRowing, .rowingSpeed,
             .distanceSkatingSports,
             .appleMoveTime, .estimatedWorkoutEffortScore, .workoutEffortScore, .physicalEffort,
             .appleWalkingSteadiness, .sixMinuteWalkTestDistance, .walkingSpeed, .walkingStepLength,
             .walkingAsymmetryPercentage, .walkingDoubleSupportPercentage,
             .stairAscentSpeed, .stairDescentSpeed:
            return .activity

        case .heartRate, .restingHeartRate, .walkingHeartRateAverage, .heartRateVariability,
             .bloodPressureSystolic, .bloodPressureDiastolic, .bloodOxygen, .respiratoryRate,
             .bodyTemperature, .vo2Max,
             .heartRateRecoveryOneMinute, .atrialFibrillationBurden,
             .bloodGlucose, .insulinDelivery, .inhalerUsage, .numberOfTimesFallen,
             .electrodermalActivity, .forcedExpiratoryVolume1, .forcedVitalCapacity,
             .peakExpiratoryFlowRate, .peripheralPerfusionIndex,
             .bloodAlcoholContent, .numberOfAlcoholicBeverages:
            return .vitals

        case .sleepAnalysis, .sleepInBed, .sleepAsleep, .sleepAwake,
             .sleepREM, .sleepCore, .sleepDeep,
             .appleSleepingWristTemperature, .appleSleepingBreathingDisturbances:
            return .sleep

        case .weight, .height, .bodyMassIndex, .bodyFatPercentage, .leanBodyMass,
             .waistCircumference, .basalBodyTemperature:
            return .body

        case .timeInDaylight, .uvExposure, .underwaterDepth, .waterTemperature:
            return .environment

        case .environmentalAudioExposure, .headphoneAudioExposure, .environmentalSoundReduction:
            return .hearing

        case .dietaryEnergyConsumed, .dietaryProtein, .dietaryCarbohydrates,
             .dietaryFatTotal, .dietaryFatSaturated, .dietaryFatMonounsaturated, .dietaryFatPolyunsaturated,
             .dietaryFiber, .dietarySugar, .dietarySodium, .dietaryPotassium, .dietaryCalcium,
             .dietaryPhosphorus, .dietaryMagnesium, .dietaryIron, .dietaryZinc, .dietarySelenium,
             .dietaryChloride, .dietaryChromium, .dietaryCopper, .dietaryIodine, .dietaryMolybdenum,
             .dietaryManganese, .dietaryNiacin, .dietaryRiboflavin, .dietaryThiamin,
             .dietaryPantothenicAcid, .dietaryBiotin, .dietaryFolate,
             .dietaryVitaminA, .dietaryVitaminB6, .dietaryVitaminB12, .dietaryVitaminC,
             .dietaryVitaminD, .dietaryVitaminE, .dietaryVitaminK,
             .dietaryCaffeine, .dietaryWater, .dietaryCholesterol:
            return .nutrition

        case .abdominalCramps, .bloating, .constipation, .diarrhea, .heartburn,
             .nausea, .vomiting, .appetiteChanges, .chills, .dizziness, .fainting,
             .fatigue, .fever, .generalizedBodyAche, .hotFlashes,
             .chestTightnessOrPain, .coughing, .rapidPoundingOrFlutteringHeartbeat,
             .shortnessOfBreath, .skippedHeartbeat, .wheezing,
             .lowerBackPain, .headache, .memoryLapse, .moodChanges,
             .lossOfSmell, .lossOfTaste, .runnyNose, .soreThroat, .sinusCongestion,
             .breastPain, .pelvicPain, .vaginalDryness,
             .acne, .drySkin, .hairLoss, .nightSweats, .sleepChanges, .bladderIncontinence:
            return .symptoms

        case .lowHeartRateEvent, .highHeartRateEvent, .irregularHeartRhythmEvent,
             .appleStandHour, .appleWalkingSteadinessEvent, .lowCardioFitnessEvent,
             .environmentalAudioExposureEvent, .headphoneAudioExposureEvent:
            return .events

        case .menstrualFlow, .intermenstrualBleeding, .infrequentMenstrualCycles,
             .irregularMenstrualCycles, .persistentIntermenstrualBleeding, .prolongedMenstrualPeriods,
             .cervicalMucusQuality, .ovulationTestResult, .progesteroneTestResult,
             .sexualActivity, .contraceptive, .pregnancy, .pregnancyTestResult, .lactation:
            return .reproductive

        case .toothbrushingEvent, .handwashingEvent:
            return .selfCare

        case .stateOfMind:
            return .stateOfMind
        }
    }

    // MARK: - Display Name
    var displayName: String {
        switch self {
        // Activity
        case .steps: return "Steps"
        case .distanceWalkingRunning: return "Walking + Running Distance"
        case .distanceCycling: return "Cycling Distance"
        case .activeEnergyBurned: return "Active Energy"
        case .basalEnergyBurned: return "Basal Energy"
        case .exerciseTime: return "Exercise Time"
        case .standHours: return "Stand Hours"
        case .flightsClimbed: return "Flights Climbed"
        case .workouts: return "Workouts"
        case .runningSpeed: return "Running Speed"
        case .runningPower: return "Running Power"
        case .runningStrideLength: return "Running Stride Length"
        case .runningGroundContactTime: return "Running Ground Contact Time"
        case .runningVerticalOscillation: return "Running Vertical Oscillation"
        case .cyclingCadence: return "Cycling Cadence"
        case .cyclingPower: return "Cycling Power"
        case .cyclingFunctionalThresholdPower: return "Cycling FTP"
        case .cyclingSpeed: return "Cycling Speed"
        case .swimmingStrokeCount: return "Swimming Stroke Count"
        case .distanceSwimming: return "Swimming Distance"
        case .distanceWheelchair: return "Wheelchair Distance"
        case .pushCount: return "Push Count"
        case .distanceDownhillSnowSports: return "Downhill Snow Sports Distance"
        case .distanceCrossCountrySkiing: return "Cross Country Skiing Distance"
        case .crossCountrySkiingSpeed: return "Cross Country Skiing Speed"
        case .distancePaddleSports: return "Paddle Sports Distance"
        case .paddleSportsSpeed: return "Paddle Sports Speed"
        case .distanceRowing: return "Rowing Distance"
        case .rowingSpeed: return "Rowing Speed"
        case .distanceSkatingSports: return "Skating Sports Distance"
        case .appleMoveTime: return "Move Time"
        case .estimatedWorkoutEffortScore: return "Estimated Workout Effort"
        case .workoutEffortScore: return "Workout Effort Score"
        case .physicalEffort: return "Physical Effort"
        // Mobility
        case .appleWalkingSteadiness: return "Walking Steadiness"
        case .sixMinuteWalkTestDistance: return "6-Minute Walk Test Distance"
        case .walkingSpeed: return "Walking Speed"
        case .walkingStepLength: return "Walking Step Length"
        case .walkingAsymmetryPercentage: return "Walking Asymmetry"
        case .walkingDoubleSupportPercentage: return "Walking Double Support"
        case .stairAscentSpeed: return "Stair Ascent Speed"
        case .stairDescentSpeed: return "Stair Descent Speed"
        // Vitals
        case .heartRate: return "Heart Rate"
        case .restingHeartRate: return "Resting Heart Rate"
        case .walkingHeartRateAverage: return "Walking HR Avg"
        case .heartRateVariability: return "HRV"
        case .bloodPressureSystolic: return "Blood Pressure Systolic"
        case .bloodPressureDiastolic: return "Blood Pressure Diastolic"
        case .bloodOxygen: return "Blood Oxygen"
        case .respiratoryRate: return "Respiratory Rate"
        case .bodyTemperature: return "Body Temperature"
        case .vo2Max: return "VO2 Max"
        case .heartRateRecoveryOneMinute: return "Heart Rate Recovery (1 min)"
        case .atrialFibrillationBurden: return "AFib Burden"
        case .bloodGlucose: return "Blood Glucose"
        case .insulinDelivery: return "Insulin Delivery"
        case .inhalerUsage: return "Inhaler Usage"
        case .numberOfTimesFallen: return "Times Fallen"
        case .electrodermalActivity: return "Electrodermal Activity"
        case .forcedExpiratoryVolume1: return "FEV1"
        case .forcedVitalCapacity: return "FVC"
        case .peakExpiratoryFlowRate: return "Peak Expiratory Flow Rate"
        case .peripheralPerfusionIndex: return "Peripheral Perfusion Index"
        case .bloodAlcoholContent: return "Blood Alcohol Content"
        case .numberOfAlcoholicBeverages: return "Alcoholic Beverages"
        // Sleep
        case .sleepAnalysis: return "Sleep Analysis"
        case .sleepInBed: return "Sleep In Bed"
        case .sleepAsleep: return "Sleep Asleep"
        case .sleepAwake: return "Sleep Awake"
        case .sleepREM: return "Sleep REM"
        case .sleepCore: return "Sleep Core"
        case .sleepDeep: return "Sleep Deep"
        case .appleSleepingWristTemperature: return "Sleeping Wrist Temperature"
        case .appleSleepingBreathingDisturbances: return "Sleeping Breathing Disturbances"
        // Body
        case .weight: return "Weight"
        case .height: return "Height"
        case .bodyMassIndex: return "Body Mass Index"
        case .bodyFatPercentage: return "Body Fat %"
        case .leanBodyMass: return "Lean Body Mass"
        case .waistCircumference: return "Waist Circumference"
        case .basalBodyTemperature: return "Basal Body Temperature"
        // Environment
        case .timeInDaylight: return "Time in Daylight"
        case .uvExposure: return "UV Exposure"
        case .underwaterDepth: return "Underwater Depth"
        case .waterTemperature: return "Water Temperature"
        // Hearing
        case .environmentalAudioExposure: return "Environmental Audio Exposure"
        case .headphoneAudioExposure: return "Headphone Audio Exposure"
        case .environmentalSoundReduction: return "Environmental Sound Reduction"
        // Nutrition
        case .dietaryEnergyConsumed: return "Dietary Energy"
        case .dietaryProtein: return "Protein"
        case .dietaryCarbohydrates: return "Carbohydrates"
        case .dietaryFatTotal: return "Total Fat"
        case .dietaryFatSaturated: return "Saturated Fat"
        case .dietaryFatMonounsaturated: return "Monounsaturated Fat"
        case .dietaryFatPolyunsaturated: return "Polyunsaturated Fat"
        case .dietaryFiber: return "Dietary Fiber"
        case .dietarySugar: return "Sugar"
        case .dietarySodium: return "Sodium"
        case .dietaryPotassium: return "Potassium"
        case .dietaryCalcium: return "Calcium"
        case .dietaryPhosphorus: return "Phosphorus"
        case .dietaryMagnesium: return "Magnesium"
        case .dietaryIron: return "Iron"
        case .dietaryZinc: return "Zinc"
        case .dietarySelenium: return "Selenium"
        case .dietaryChloride: return "Chloride"
        case .dietaryChromium: return "Chromium"
        case .dietaryCopper: return "Copper"
        case .dietaryIodine: return "Iodine"
        case .dietaryMolybdenum: return "Molybdenum"
        case .dietaryManganese: return "Manganese"
        case .dietaryNiacin: return "Niacin (B3)"
        case .dietaryRiboflavin: return "Riboflavin (B2)"
        case .dietaryThiamin: return "Thiamin (B1)"
        case .dietaryPantothenicAcid: return "Pantothenic Acid (B5)"
        case .dietaryBiotin: return "Biotin (B7)"
        case .dietaryFolate: return "Folate (B9)"
        case .dietaryVitaminA: return "Vitamin A"
        case .dietaryVitaminB6: return "Vitamin B6"
        case .dietaryVitaminB12: return "Vitamin B12"
        case .dietaryVitaminC: return "Vitamin C"
        case .dietaryVitaminD: return "Vitamin D"
        case .dietaryVitaminE: return "Vitamin E"
        case .dietaryVitaminK: return "Vitamin K"
        case .dietaryCaffeine: return "Caffeine"
        case .dietaryWater: return "Water Intake"
        case .dietaryCholesterol: return "Cholesterol"
        // Symptoms
        case .abdominalCramps: return "Abdominal Cramps"
        case .bloating: return "Bloating"
        case .constipation: return "Constipation"
        case .diarrhea: return "Diarrhea"
        case .heartburn: return "Heartburn"
        case .nausea: return "Nausea"
        case .vomiting: return "Vomiting"
        case .appetiteChanges: return "Appetite Changes"
        case .chills: return "Chills"
        case .dizziness: return "Dizziness"
        case .fainting: return "Fainting"
        case .fatigue: return "Fatigue"
        case .fever: return "Fever"
        case .generalizedBodyAche: return "Generalized Body Ache"
        case .hotFlashes: return "Hot Flashes"
        case .chestTightnessOrPain: return "Chest Tightness / Pain"
        case .coughing: return "Coughing"
        case .rapidPoundingOrFlutteringHeartbeat: return "Rapid / Pounding Heartbeat"
        case .shortnessOfBreath: return "Shortness of Breath"
        case .skippedHeartbeat: return "Skipped Heartbeat"
        case .wheezing: return "Wheezing"
        case .lowerBackPain: return "Lower Back Pain"
        case .headache: return "Headache"
        case .memoryLapse: return "Memory Lapse"
        case .moodChanges: return "Mood Changes"
        case .lossOfSmell: return "Loss of Smell"
        case .lossOfTaste: return "Loss of Taste"
        case .runnyNose: return "Runny Nose"
        case .soreThroat: return "Sore Throat"
        case .sinusCongestion: return "Sinus Congestion"
        case .breastPain: return "Breast Pain"
        case .pelvicPain: return "Pelvic Pain"
        case .vaginalDryness: return "Vaginal Dryness"
        case .acne: return "Acne"
        case .drySkin: return "Dry Skin"
        case .hairLoss: return "Hair Loss"
        case .nightSweats: return "Night Sweats"
        case .sleepChanges: return "Sleep Changes"
        case .bladderIncontinence: return "Bladder Incontinence"
        // Events
        case .lowHeartRateEvent: return "Low Heart Rate Event"
        case .highHeartRateEvent: return "High Heart Rate Event"
        case .irregularHeartRhythmEvent: return "Irregular Heart Rhythm Event"
        case .appleStandHour: return "Stand Hour"
        case .appleWalkingSteadinessEvent: return "Walking Steadiness Event"
        case .lowCardioFitnessEvent: return "Low Cardio Fitness Event"
        case .environmentalAudioExposureEvent: return "Environmental Audio Exposure Event"
        case .headphoneAudioExposureEvent: return "Headphone Audio Exposure Event"
        // Reproductive
        case .menstrualFlow: return "Menstrual Flow"
        case .intermenstrualBleeding: return "Intermenstrual Bleeding"
        case .infrequentMenstrualCycles: return "Infrequent Menstrual Cycles"
        case .irregularMenstrualCycles: return "Irregular Menstrual Cycles"
        case .persistentIntermenstrualBleeding: return "Persistent Intermenstrual Bleeding"
        case .prolongedMenstrualPeriods: return "Prolonged Menstrual Periods"
        case .cervicalMucusQuality: return "Cervical Mucus Quality"
        case .ovulationTestResult: return "Ovulation Test Result"
        case .progesteroneTestResult: return "Progesterone Test Result"
        case .sexualActivity: return "Sexual Activity"
        case .contraceptive: return "Contraceptive"
        case .pregnancy: return "Pregnancy"
        case .pregnancyTestResult: return "Pregnancy Test Result"
        case .lactation: return "Lactation"
        // Self Care
        case .toothbrushingEvent: return "Toothbrushing"
        case .handwashingEvent: return "Handwashing"
        // State of Mind
        case .stateOfMind: return "State of Mind"
        }
    }

    // MARK: - Sample Type
    var sampleType: HKSampleType? {
        switch self {
        // Activity - existing
        case .steps: return HKObjectType.quantityType(forIdentifier: .stepCount)
        case .distanceWalkingRunning: return HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)
        case .distanceCycling: return HKObjectType.quantityType(forIdentifier: .distanceCycling)
        case .activeEnergyBurned: return HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
        case .basalEnergyBurned: return HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)
        case .exerciseTime: return HKObjectType.quantityType(forIdentifier: .appleExerciseTime)
        case .standHours: return HKObjectType.quantityType(forIdentifier: .appleStandTime)
        case .flightsClimbed: return HKObjectType.quantityType(forIdentifier: .flightsClimbed)
        case .workouts: return HKObjectType.workoutType()
        // Activity - new
        case .runningSpeed: return HKObjectType.quantityType(forIdentifier: .runningSpeed)
        case .runningPower: return HKObjectType.quantityType(forIdentifier: .runningPower)
        case .runningStrideLength: return HKObjectType.quantityType(forIdentifier: .runningStrideLength)
        case .runningGroundContactTime: return HKObjectType.quantityType(forIdentifier: .runningGroundContactTime)
        case .runningVerticalOscillation: return HKObjectType.quantityType(forIdentifier: .runningVerticalOscillation)
        case .cyclingCadence: return HKObjectType.quantityType(forIdentifier: .cyclingCadence)
        case .cyclingPower: return HKObjectType.quantityType(forIdentifier: .cyclingPower)
        case .cyclingFunctionalThresholdPower: return HKObjectType.quantityType(forIdentifier: .cyclingFunctionalThresholdPower)
        case .cyclingSpeed: return HKObjectType.quantityType(forIdentifier: .cyclingSpeed)
        case .swimmingStrokeCount: return HKObjectType.quantityType(forIdentifier: .swimmingStrokeCount)
        case .distanceSwimming: return HKObjectType.quantityType(forIdentifier: .distanceSwimming)
        case .distanceWheelchair: return HKObjectType.quantityType(forIdentifier: .distanceWheelchair)
        case .pushCount: return HKObjectType.quantityType(forIdentifier: .pushCount)
        case .distanceDownhillSnowSports: return HKObjectType.quantityType(forIdentifier: .distanceDownhillSnowSports)
        case .distanceCrossCountrySkiing: return HKObjectType.quantityType(forIdentifier: .distanceCrossCountrySkiing)
        case .crossCountrySkiingSpeed: return HKObjectType.quantityType(forIdentifier: .crossCountrySkiingSpeed)
        case .distancePaddleSports: return HKObjectType.quantityType(forIdentifier: .distancePaddleSports)
        case .paddleSportsSpeed: return HKObjectType.quantityType(forIdentifier: .paddleSportsSpeed)
        case .distanceRowing: return HKObjectType.quantityType(forIdentifier: .distanceRowing)
        case .rowingSpeed: return HKObjectType.quantityType(forIdentifier: .rowingSpeed)
        case .distanceSkatingSports: return HKObjectType.quantityType(forIdentifier: .distanceSkatingSports)
        case .appleMoveTime: return HKObjectType.quantityType(forIdentifier: .appleMoveTime)
        case .estimatedWorkoutEffortScore: return HKObjectType.quantityType(forIdentifier: .estimatedWorkoutEffortScore)
        case .workoutEffortScore: return HKObjectType.quantityType(forIdentifier: .workoutEffortScore)
        case .physicalEffort: return HKObjectType.quantityType(forIdentifier: .physicalEffort)
        // Mobility
        case .appleWalkingSteadiness: return HKObjectType.quantityType(forIdentifier: .appleWalkingSteadiness)
        case .sixMinuteWalkTestDistance: return HKObjectType.quantityType(forIdentifier: .sixMinuteWalkTestDistance)
        case .walkingSpeed: return HKObjectType.quantityType(forIdentifier: .walkingSpeed)
        case .walkingStepLength: return HKObjectType.quantityType(forIdentifier: .walkingStepLength)
        case .walkingAsymmetryPercentage: return HKObjectType.quantityType(forIdentifier: .walkingAsymmetryPercentage)
        case .walkingDoubleSupportPercentage: return HKObjectType.quantityType(forIdentifier: .walkingDoubleSupportPercentage)
        case .stairAscentSpeed: return HKObjectType.quantityType(forIdentifier: .stairAscentSpeed)
        case .stairDescentSpeed: return HKObjectType.quantityType(forIdentifier: .stairDescentSpeed)
        // Vitals - existing
        case .heartRate: return HKObjectType.quantityType(forIdentifier: .heartRate)
        case .restingHeartRate: return HKObjectType.quantityType(forIdentifier: .restingHeartRate)
        case .walkingHeartRateAverage: return HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)
        case .heartRateVariability: return HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)
        case .bloodPressureSystolic: return HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)
        case .bloodPressureDiastolic: return HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)
        case .bloodOxygen: return HKObjectType.quantityType(forIdentifier: .oxygenSaturation)
        case .respiratoryRate: return HKObjectType.quantityType(forIdentifier: .respiratoryRate)
        case .bodyTemperature: return HKObjectType.quantityType(forIdentifier: .bodyTemperature)
        case .vo2Max: return HKObjectType.quantityType(forIdentifier: .vo2Max)
        // Vitals - new
        case .heartRateRecoveryOneMinute: return HKObjectType.quantityType(forIdentifier: .heartRateRecoveryOneMinute)
        case .atrialFibrillationBurden: return HKObjectType.quantityType(forIdentifier: .atrialFibrillationBurden)
        case .bloodGlucose: return HKObjectType.quantityType(forIdentifier: .bloodGlucose)
        case .insulinDelivery: return HKObjectType.quantityType(forIdentifier: .insulinDelivery)
        case .inhalerUsage: return HKObjectType.quantityType(forIdentifier: .inhalerUsage)
        case .numberOfTimesFallen: return HKObjectType.quantityType(forIdentifier: .numberOfTimesFallen)
        case .electrodermalActivity: return HKObjectType.quantityType(forIdentifier: .electrodermalActivity)
        case .forcedExpiratoryVolume1: return HKObjectType.quantityType(forIdentifier: .forcedExpiratoryVolume1)
        case .forcedVitalCapacity: return HKObjectType.quantityType(forIdentifier: .forcedVitalCapacity)
        case .peakExpiratoryFlowRate: return HKObjectType.quantityType(forIdentifier: .peakExpiratoryFlowRate)
        case .peripheralPerfusionIndex: return HKObjectType.quantityType(forIdentifier: .peripheralPerfusionIndex)
        case .bloodAlcoholContent: return HKObjectType.quantityType(forIdentifier: .bloodAlcoholContent)
        case .numberOfAlcoholicBeverages: return HKObjectType.quantityType(forIdentifier: .numberOfAlcoholicBeverages)
        // Sleep - existing
        case .sleepAnalysis: return HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        case .sleepInBed: return HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        case .sleepAsleep: return HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        case .sleepAwake: return HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        case .sleepREM: return HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        case .sleepCore: return HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        case .sleepDeep: return HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        // Sleep - new
        case .appleSleepingWristTemperature: return HKObjectType.quantityType(forIdentifier: .appleSleepingWristTemperature)
        case .appleSleepingBreathingDisturbances: return HKObjectType.quantityType(forIdentifier: .appleSleepingBreathingDisturbances)
        // Body - existing
        case .weight: return HKObjectType.quantityType(forIdentifier: .bodyMass)
        case .height: return HKObjectType.quantityType(forIdentifier: .height)
        case .bodyMassIndex: return HKObjectType.quantityType(forIdentifier: .bodyMassIndex)
        case .bodyFatPercentage: return HKObjectType.quantityType(forIdentifier: .bodyFatPercentage)
        case .leanBodyMass: return HKObjectType.quantityType(forIdentifier: .leanBodyMass)
        // Body - new
        case .waistCircumference: return HKObjectType.quantityType(forIdentifier: .waistCircumference)
        case .basalBodyTemperature: return HKObjectType.quantityType(forIdentifier: .basalBodyTemperature)
        // Environment
        case .timeInDaylight: return HKObjectType.quantityType(forIdentifier: .timeInDaylight)
        case .uvExposure: return HKObjectType.quantityType(forIdentifier: .uvExposure)
        case .underwaterDepth: return HKObjectType.quantityType(forIdentifier: .underwaterDepth)
        case .waterTemperature: return HKObjectType.quantityType(forIdentifier: .waterTemperature)
        // Hearing
        case .environmentalAudioExposure: return HKObjectType.quantityType(forIdentifier: .environmentalAudioExposure)
        case .headphoneAudioExposure: return HKObjectType.quantityType(forIdentifier: .headphoneAudioExposure)
        case .environmentalSoundReduction: return HKObjectType.quantityType(forIdentifier: .environmentalSoundReduction)
        // Nutrition
        case .dietaryEnergyConsumed: return HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)
        case .dietaryProtein: return HKObjectType.quantityType(forIdentifier: .dietaryProtein)
        case .dietaryCarbohydrates: return HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)
        case .dietaryFatTotal: return HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)
        case .dietaryFatSaturated: return HKObjectType.quantityType(forIdentifier: .dietaryFatSaturated)
        case .dietaryFatMonounsaturated: return HKObjectType.quantityType(forIdentifier: .dietaryFatMonounsaturated)
        case .dietaryFatPolyunsaturated: return HKObjectType.quantityType(forIdentifier: .dietaryFatPolyunsaturated)
        case .dietaryFiber: return HKObjectType.quantityType(forIdentifier: .dietaryFiber)
        case .dietarySugar: return HKObjectType.quantityType(forIdentifier: .dietarySugar)
        case .dietarySodium: return HKObjectType.quantityType(forIdentifier: .dietarySodium)
        case .dietaryPotassium: return HKObjectType.quantityType(forIdentifier: .dietaryPotassium)
        case .dietaryCalcium: return HKObjectType.quantityType(forIdentifier: .dietaryCalcium)
        case .dietaryPhosphorus: return HKObjectType.quantityType(forIdentifier: .dietaryPhosphorus)
        case .dietaryMagnesium: return HKObjectType.quantityType(forIdentifier: .dietaryMagnesium)
        case .dietaryIron: return HKObjectType.quantityType(forIdentifier: .dietaryIron)
        case .dietaryZinc: return HKObjectType.quantityType(forIdentifier: .dietaryZinc)
        case .dietarySelenium: return HKObjectType.quantityType(forIdentifier: .dietarySelenium)
        case .dietaryChloride: return HKObjectType.quantityType(forIdentifier: .dietaryChloride)
        case .dietaryChromium: return HKObjectType.quantityType(forIdentifier: .dietaryChromium)
        case .dietaryCopper: return HKObjectType.quantityType(forIdentifier: .dietaryCopper)
        case .dietaryIodine: return HKObjectType.quantityType(forIdentifier: .dietaryIodine)
        case .dietaryMolybdenum: return HKObjectType.quantityType(forIdentifier: .dietaryMolybdenum)
        case .dietaryManganese: return HKObjectType.quantityType(forIdentifier: .dietaryManganese)
        case .dietaryNiacin: return HKObjectType.quantityType(forIdentifier: .dietaryNiacin)
        case .dietaryRiboflavin: return HKObjectType.quantityType(forIdentifier: .dietaryRiboflavin)
        case .dietaryThiamin: return HKObjectType.quantityType(forIdentifier: .dietaryThiamin)
        case .dietaryPantothenicAcid: return HKObjectType.quantityType(forIdentifier: .dietaryPantothenicAcid)
        case .dietaryBiotin: return HKObjectType.quantityType(forIdentifier: .dietaryBiotin)
        case .dietaryFolate: return HKObjectType.quantityType(forIdentifier: .dietaryFolate)
        case .dietaryVitaminA: return HKObjectType.quantityType(forIdentifier: .dietaryVitaminA)
        case .dietaryVitaminB6: return HKObjectType.quantityType(forIdentifier: .dietaryVitaminB6)
        case .dietaryVitaminB12: return HKObjectType.quantityType(forIdentifier: .dietaryVitaminB12)
        case .dietaryVitaminC: return HKObjectType.quantityType(forIdentifier: .dietaryVitaminC)
        case .dietaryVitaminD: return HKObjectType.quantityType(forIdentifier: .dietaryVitaminD)
        case .dietaryVitaminE: return HKObjectType.quantityType(forIdentifier: .dietaryVitaminE)
        case .dietaryVitaminK: return HKObjectType.quantityType(forIdentifier: .dietaryVitaminK)
        case .dietaryCaffeine: return HKObjectType.quantityType(forIdentifier: .dietaryCaffeine)
        case .dietaryWater: return HKObjectType.quantityType(forIdentifier: .dietaryWater)
        case .dietaryCholesterol: return HKObjectType.quantityType(forIdentifier: .dietaryCholesterol)
        // Symptoms
        case .abdominalCramps: return HKObjectType.categoryType(forIdentifier: .abdominalCramps)
        case .bloating: return HKObjectType.categoryType(forIdentifier: .bloating)
        case .constipation: return HKObjectType.categoryType(forIdentifier: .constipation)
        case .diarrhea: return HKObjectType.categoryType(forIdentifier: .diarrhea)
        case .heartburn: return HKObjectType.categoryType(forIdentifier: .heartburn)
        case .nausea: return HKObjectType.categoryType(forIdentifier: .nausea)
        case .vomiting: return HKObjectType.categoryType(forIdentifier: .vomiting)
        case .appetiteChanges: return HKObjectType.categoryType(forIdentifier: .appetiteChanges)
        case .chills: return HKObjectType.categoryType(forIdentifier: .chills)
        case .dizziness: return HKObjectType.categoryType(forIdentifier: .dizziness)
        case .fainting: return HKObjectType.categoryType(forIdentifier: .fainting)
        case .fatigue: return HKObjectType.categoryType(forIdentifier: .fatigue)
        case .fever: return HKObjectType.categoryType(forIdentifier: .fever)
        case .generalizedBodyAche: return HKObjectType.categoryType(forIdentifier: .generalizedBodyAche)
        case .hotFlashes: return HKObjectType.categoryType(forIdentifier: .hotFlashes)
        case .chestTightnessOrPain: return HKObjectType.categoryType(forIdentifier: .chestTightnessOrPain)
        case .coughing: return HKObjectType.categoryType(forIdentifier: .coughing)
        case .rapidPoundingOrFlutteringHeartbeat: return HKObjectType.categoryType(forIdentifier: .rapidPoundingOrFlutteringHeartbeat)
        case .shortnessOfBreath: return HKObjectType.categoryType(forIdentifier: .shortnessOfBreath)
        case .skippedHeartbeat: return HKObjectType.categoryType(forIdentifier: .skippedHeartbeat)
        case .wheezing: return HKObjectType.categoryType(forIdentifier: .wheezing)
        case .lowerBackPain: return HKObjectType.categoryType(forIdentifier: .lowerBackPain)
        case .headache: return HKObjectType.categoryType(forIdentifier: .headache)
        case .memoryLapse: return HKObjectType.categoryType(forIdentifier: .memoryLapse)
        case .moodChanges: return HKObjectType.categoryType(forIdentifier: .moodChanges)
        case .lossOfSmell: return HKObjectType.categoryType(forIdentifier: .lossOfSmell)
        case .lossOfTaste: return HKObjectType.categoryType(forIdentifier: .lossOfTaste)
        case .runnyNose: return HKObjectType.categoryType(forIdentifier: .runnyNose)
        case .soreThroat: return HKObjectType.categoryType(forIdentifier: .soreThroat)
        case .sinusCongestion: return HKObjectType.categoryType(forIdentifier: .sinusCongestion)
        case .breastPain: return HKObjectType.categoryType(forIdentifier: .breastPain)
        case .pelvicPain: return HKObjectType.categoryType(forIdentifier: .pelvicPain)
        case .vaginalDryness: return HKObjectType.categoryType(forIdentifier: .vaginalDryness)
        case .acne: return HKObjectType.categoryType(forIdentifier: .acne)
        case .drySkin: return HKObjectType.categoryType(forIdentifier: .drySkin)
        case .hairLoss: return HKObjectType.categoryType(forIdentifier: .hairLoss)
        case .nightSweats: return HKObjectType.categoryType(forIdentifier: .nightSweats)
        case .sleepChanges: return HKObjectType.categoryType(forIdentifier: .sleepChanges)
        case .bladderIncontinence: return HKObjectType.categoryType(forIdentifier: .bladderIncontinence)
        // Events
        case .lowHeartRateEvent: return HKObjectType.categoryType(forIdentifier: .lowHeartRateEvent)
        case .highHeartRateEvent: return HKObjectType.categoryType(forIdentifier: .highHeartRateEvent)
        case .irregularHeartRhythmEvent: return HKObjectType.categoryType(forIdentifier: .irregularHeartRhythmEvent)
        case .appleStandHour: return HKObjectType.categoryType(forIdentifier: .appleStandHour)
        case .appleWalkingSteadinessEvent: return HKObjectType.categoryType(forIdentifier: .appleWalkingSteadinessEvent)
        case .lowCardioFitnessEvent: return HKObjectType.categoryType(forIdentifier: .lowCardioFitnessEvent)
        case .environmentalAudioExposureEvent: return HKObjectType.categoryType(forIdentifier: .environmentalAudioExposureEvent)
        case .headphoneAudioExposureEvent: return HKObjectType.categoryType(forIdentifier: .headphoneAudioExposureEvent)
        // Reproductive
        case .menstrualFlow: return HKObjectType.categoryType(forIdentifier: .menstrualFlow)
        case .intermenstrualBleeding: return HKObjectType.categoryType(forIdentifier: .intermenstrualBleeding)
        case .infrequentMenstrualCycles: return HKObjectType.categoryType(forIdentifier: .infrequentMenstrualCycles)
        case .irregularMenstrualCycles: return HKObjectType.categoryType(forIdentifier: .irregularMenstrualCycles)
        case .persistentIntermenstrualBleeding: return HKObjectType.categoryType(forIdentifier: .persistentIntermenstrualBleeding)
        case .prolongedMenstrualPeriods: return HKObjectType.categoryType(forIdentifier: .prolongedMenstrualPeriods)
        case .cervicalMucusQuality: return HKObjectType.categoryType(forIdentifier: .cervicalMucusQuality)
        case .ovulationTestResult: return HKObjectType.categoryType(forIdentifier: .ovulationTestResult)
        case .progesteroneTestResult: return HKObjectType.categoryType(forIdentifier: .progesteroneTestResult)
        case .sexualActivity: return HKObjectType.categoryType(forIdentifier: .sexualActivity)
        case .contraceptive: return HKObjectType.categoryType(forIdentifier: .contraceptive)
        case .pregnancy: return HKObjectType.categoryType(forIdentifier: .pregnancy)
        case .pregnancyTestResult: return HKObjectType.categoryType(forIdentifier: .pregnancyTestResult)
        case .lactation: return HKObjectType.categoryType(forIdentifier: .lactation)
        // Self Care
        case .toothbrushingEvent: return HKObjectType.categoryType(forIdentifier: .toothbrushingEvent)
        case .handwashingEvent: return HKObjectType.categoryType(forIdentifier: .handwashingEvent)
        // State of Mind — requires HKStateOfMindQuery, not HKSampleQuery
        case .stateOfMind: return nil
        }
    }

    // MARK: - Sleep Type Filter
    var isCategorySleepType: Bool {
        switch self {
        case .sleepAnalysis, .sleepInBed, .sleepAsleep, .sleepAwake, .sleepREM, .sleepCore, .sleepDeep:
            return true
        default:
            return false
        }
    }
}
