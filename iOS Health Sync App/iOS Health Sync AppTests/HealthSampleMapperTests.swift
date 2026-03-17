// Copyright 2026 Marcus Neves
// SPDX-License-Identifier: Apache-2.0

import HealthKit
import Testing
@testable import iOS_Health_Sync_App

private let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)

private let sampleDTO = NutritionWriteDTO(
    id: 42,
    name: "테스트 식사",
    eatenAt: fixedDate,
    calories: 500,
    proteinG: 30,
    carbsG: 60,
    fatG: 15,
    fiberG: 8,
    sodiumMg: 800,
    sugarG: 10
)

@Test
func testCreateNutritionCorrelation_returns7Samples() throws {
    let correlation = try HealthSampleMapper.createNutritionCorrelation(from: sampleDTO)
    #expect(correlation.objects.count == 7)
    #expect(correlation.correlationType == HKCorrelationType(.food))
}

@Test
func testCreateNutritionCorrelation_hasRequiredMetadata() throws {
    let correlation = try HealthSampleMapper.createNutritionCorrelation(from: sampleDTO)
    let metadata = correlation.metadata
    #expect(metadata?[HKMetadataKeySyncIdentifier] as? String == "vitalery-meal-42")
    #expect(metadata?[HKMetadataKeySyncVersion] as? Int == 1)
    #expect(metadata?[HKMetadataKeyWasUserEntered] as? Bool == true)
    #expect(metadata?[HKMetadataKeyFoodType] as? String == "테스트 식사")
}

@Test
func testCreateNutritionCorrelation_sodiumUnit() throws {
    let correlation = try HealthSampleMapper.createNutritionCorrelation(from: sampleDTO)
    let sodiumType = HKQuantityType(.dietarySodium)
    let sodiumSample = correlation.objects
        .compactMap { $0 as? HKQuantitySample }
        .first { $0.quantityType == sodiumType }
    #expect(sodiumSample != nil)
    #expect(sodiumSample?.quantity.doubleValue(for: .gramUnit(with: .milli)) == 800)
}

@Test
func testZeroValueNutrition_correlationStillCreated() throws {
    let zeroDTO = NutritionWriteDTO(
        id: 0,
        name: "빈 식사",
        eatenAt: fixedDate,
        calories: 0,
        proteinG: 0,
        carbsG: 0,
        fatG: 0,
        fiberG: 0,
        sodiumMg: 0,
        sugarG: 0
    )
    let correlation = try HealthSampleMapper.createNutritionCorrelation(from: zeroDTO)
    #expect(correlation.objects.count == 7)
}
