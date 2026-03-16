// Copyright 2026 Marcus Neves
// SPDX-License-Identifier: Apache-2.0

@preconcurrency import HealthKit
import Foundation

struct HealthSampleMapper {
    static func mapSample(_ sample: HKSample, requestedType: HealthDataType) -> HealthSampleDTO? {
        let sourceName = sample.sourceRevision.source.name
        if let quantitySample = sample as? HKQuantitySample {
            let unit = unitForQuantityType(requestedType)
            let value = quantitySample.quantity.doubleValue(for: unit)
            return HealthSampleDTO(
                id: quantitySample.uuid,
                type: requestedType.rawValue,
                value: value,
                unit: unit.unitString,
                startDate: quantitySample.startDate,
                endDate: quantitySample.endDate,
                sourceName: sourceName,
                metadata: nil
            )
        }

        if let categorySample = sample as? HKCategorySample {
            if requestedType.isCategorySleepType, !matchesSleepType(requestedType, categorySample: categorySample) {
                return nil
            }
            let metadata = sleepMetadata(for: categorySample)
            return HealthSampleDTO(
                id: categorySample.uuid,
                type: requestedType.rawValue,
                value: Double(categorySample.value),
                unit: "category",
                startDate: categorySample.startDate,
                endDate: categorySample.endDate,
                sourceName: sourceName,
                metadata: metadata
            )
        }

        if let workout = sample as? HKWorkout {
            var metadata: [String: String] = [
                "activityType": workout.workoutActivityType.name,
                "durationSeconds": String(format: "%.0f", workout.duration)
            ]
            if let energy = activeEnergyKilocalories(for: workout) {
                metadata["totalEnergyKilocalories"] = String(format: "%.2f", energy)
            }
            if let distance = workout.totalDistance?.doubleValue(for: .meter()) {
                metadata["totalDistanceMeters"] = String(format: "%.2f", distance)
            }

            return HealthSampleDTO(
                id: workout.uuid,
                type: HealthDataType.workouts.rawValue,
                value: workout.duration,
                unit: "s",
                startDate: workout.startDate,
                endDate: workout.endDate,
                sourceName: sourceName,
                metadata: metadata
            )
        }

        return nil
    }

    static func matchesSleepType(_ requested: HealthDataType, categorySample: HKCategorySample) -> Bool {
        guard let category = HKCategoryValueSleepAnalysis(rawValue: categorySample.value) else { return false }
        switch requested {
        case .sleepAnalysis:
            return true
        case .sleepInBed:
            return category == .inBed
        case .sleepAsleep:
            return category == .asleepUnspecified
        case .sleepAwake:
            return category == .awake
        case .sleepREM:
            return category == .asleepREM
        case .sleepCore:
            return category == .asleepCore
        case .sleepDeep:
            return category == .asleepDeep
        default:
            return true
        }
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    static func unitForQuantityType(_ type: HealthDataType) -> HKUnit {
        switch type {
        // Activity - counts
        case .steps, .standHours, .flightsClimbed, .swimmingStrokeCount, .pushCount,
             .estimatedWorkoutEffortScore, .workoutEffortScore, .physicalEffort,
             .inhalerUsage, .numberOfTimesFallen, .numberOfAlcoholicBeverages, .uvExposure:
            return .count()
        // Activity - distances (meters)
        case .distanceWalkingRunning, .distanceCycling, .distanceSwimming,
             .distanceWheelchair, .distanceDownhillSnowSports, .distanceCrossCountrySkiing,
             .distancePaddleSports, .distanceRowing, .distanceSkatingSports,
             .sixMinuteWalkTestDistance, .walkingStepLength, .underwaterDepth,
             .waistCircumference, .height, .runningStrideLength, .runningVerticalOscillation:
            return .meter()
        // Activity - energy
        case .activeEnergyBurned, .basalEnergyBurned, .dietaryEnergyConsumed:
            return .kilocalorie()
        // Activity - time
        case .exerciseTime, .appleMoveTime:
            return .minute()
        case .runningGroundContactTime, .timeInDaylight:
            return .second()
        // Activity - speed (m/s)
        case .runningSpeed, .cyclingSpeed, .crossCountrySkiingSpeed,
             .paddleSportsSpeed, .rowingSpeed, .walkingSpeed,
             .stairAscentSpeed, .stairDescentSpeed:
            return HKUnit(from: "m/s")
        // Activity - power (watts)
        case .runningPower, .cyclingPower, .cyclingFunctionalThresholdPower:
            return .watt()
        // Activity - cadence
        case .cyclingCadence:
            return HKUnit.count().unitDivided(by: .minute())
        // Mobility - percentages
        case .walkingAsymmetryPercentage, .walkingDoubleSupportPercentage, .appleWalkingSteadiness:
            return .percent()
        // Vitals - heart rate
        case .heartRate, .restingHeartRate, .walkingHeartRateAverage, .heartRateRecoveryOneMinute:
            return .count().unitDivided(by: .minute())
        case .heartRateVariability:
            return .second()
        case .atrialFibrillationBurden:
            return .percent()
        // Vitals - blood pressure
        case .bloodPressureSystolic, .bloodPressureDiastolic:
            return .millimeterOfMercury()
        // Vitals - percentages
        case .bloodOxygen, .bodyFatPercentage, .bloodAlcoholContent, .peripheralPerfusionIndex:
            return .percent()
        // Vitals - rates
        case .respiratoryRate:
            return .count().unitDivided(by: .minute())
        // Vitals - temperature
        case .bodyTemperature, .basalBodyTemperature, .appleSleepingWristTemperature, .waterTemperature:
            return .degreeCelsius()
        // Vitals - fitness
        case .vo2Max:
            return HKUnit(from: "ml/kg*min")
        // Vitals - glucose
        case .bloodGlucose:
            return HKUnit(from: "mg/dL")
        // Vitals - insulin
        case .insulinDelivery:
            return .internationalUnit()
        // Vitals - electrodermal
        case .electrodermalActivity:
            return HKUnit(from: "mcS")
        // Vitals - lung function
        case .forcedExpiratoryVolume1, .forcedVitalCapacity:
            return .liter()
        case .peakExpiratoryFlowRate:
            return HKUnit(from: "L/min")
        // Vitals - sleep breathing
        case .appleSleepingBreathingDisturbances:
            return HKUnit.count().unitDivided(by: .hour())
        // Body
        case .weight, .leanBodyMass:
            return .gramUnit(with: .kilo)
        case .bodyMassIndex:
            return .count()
        // Hearing - dBASPL
        case .environmentalAudioExposure, .headphoneAudioExposure, .environmentalSoundReduction:
            return .decibelAWeightedSoundPressureLevel()
        // Nutrition - energy
        // (dietaryEnergyConsumed handled above)
        // Nutrition - water
        case .dietaryWater:
            return .literUnit(with: .milli)
        // Nutrition - mass (grams for all remaining macros/micronutrients)
        case .dietaryProtein, .dietaryCarbohydrates, .dietaryFatTotal, .dietaryFatSaturated,
             .dietaryFatMonounsaturated, .dietaryFatPolyunsaturated, .dietaryFiber, .dietarySugar,
             .dietarySodium, .dietaryPotassium, .dietaryCalcium, .dietaryPhosphorus,
             .dietaryMagnesium, .dietaryIron, .dietaryZinc, .dietarySelenium, .dietaryChloride,
             .dietaryChromium, .dietaryCopper, .dietaryIodine, .dietaryMolybdenum,
             .dietaryManganese, .dietaryNiacin, .dietaryRiboflavin, .dietaryThiamin,
             .dietaryPantothenicAcid, .dietaryBiotin, .dietaryFolate,
             .dietaryVitaminA, .dietaryVitaminB6, .dietaryVitaminB12, .dietaryVitaminC,
             .dietaryVitaminD, .dietaryVitaminE, .dietaryVitaminK,
             .dietaryCaffeine, .dietaryCholesterol:
            return .gram()
        // Category types — unit not used for quantity reading, return count as placeholder
        case .sleepAnalysis, .sleepInBed, .sleepAsleep, .sleepAwake, .sleepREM, .sleepCore, .sleepDeep,
             .workouts,
             .abdominalCramps, .bloating, .constipation, .diarrhea, .heartburn,
             .nausea, .vomiting, .appetiteChanges, .chills, .dizziness, .fainting,
             .fatigue, .fever, .generalizedBodyAche, .hotFlashes,
             .chestTightnessOrPain, .coughing, .rapidPoundingOrFlutteringHeartbeat,
             .shortnessOfBreath, .skippedHeartbeat, .wheezing,
             .lowerBackPain, .headache, .memoryLapse, .moodChanges,
             .lossOfSmell, .lossOfTaste, .runnyNose, .soreThroat, .sinusCongestion,
             .breastPain, .pelvicPain, .vaginalDryness,
             .acne, .drySkin, .hairLoss, .nightSweats, .sleepChanges, .bladderIncontinence,
             .lowHeartRateEvent, .highHeartRateEvent, .irregularHeartRhythmEvent,
             .appleStandHour, .appleWalkingSteadinessEvent, .lowCardioFitnessEvent,
             .environmentalAudioExposureEvent, .headphoneAudioExposureEvent,
             .menstrualFlow, .intermenstrualBleeding, .infrequentMenstrualCycles,
             .irregularMenstrualCycles, .persistentIntermenstrualBleeding, .prolongedMenstrualPeriods,
             .cervicalMucusQuality, .ovulationTestResult, .progesteroneTestResult,
             .sexualActivity, .contraceptive, .pregnancy, .pregnancyTestResult, .lactation,
             .toothbrushingEvent, .handwashingEvent,
             .stateOfMind:
            return .count()
        }
    }

    static func sleepMetadata(for sample: HKCategorySample) -> [String: String]? {
        guard let category = HKCategoryValueSleepAnalysis(rawValue: sample.value) else {
            return nil
        }
        let stage: String
        switch category {
        case .inBed: stage = "inBed"
        case .asleepUnspecified: stage = "asleep"
        case .awake: stage = "awake"
        case .asleepREM: stage = "rem"
        case .asleepCore: stage = "core"
        case .asleepDeep: stage = "deep"
        @unknown default: stage = "unknown"
        }
        return ["sleepStage": stage]
    }

    private static func activeEnergyKilocalories(for workout: HKWorkout) -> Double? {
        if #available(iOS 18.0, *) {
            let quantityType = HKQuantityType(.activeEnergyBurned)
            if let stats = workout.statistics(for: quantityType), let quantity = stats.sumQuantity() {
                return quantity.doubleValue(for: .kilocalorie())
            }
            return nil
        } else {
            return workout.totalEnergyBurned?.doubleValue(for: .kilocalorie())
        }
    }
}

private extension HKWorkoutActivityType {
    var name: String {
        switch self {
        case .running: return "running"
        case .walking: return "walking"
        case .cycling: return "cycling"
        case .swimming: return "swimming"
        case .yoga: return "yoga"
        default: return "other"
        }
    }
}
