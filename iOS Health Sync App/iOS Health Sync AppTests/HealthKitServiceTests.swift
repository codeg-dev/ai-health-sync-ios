// Copyright 2026 Marcus Neves
// SPDX-License-Identifier: Apache-2.0

import HealthKit
import Testing
@testable import iOS_Health_Sync_App

struct MockHealthStore: HealthStoreProtocol {
    var requestedReadTypes: Set<HKObjectType> = []
    var authorizationStatusMap: [HKObjectType: HKAuthorizationStatus] = [:]
    var authorizationRequestStatus: HKAuthorizationRequestStatus = .shouldRequest

    func requestAuthorization(toShare typesToShare: Set<HKSampleType>?, read typesToRead: Set<HKObjectType>?, completion: @escaping @Sendable (Bool, Error?) -> Void) {
        completion(true, nil)
    }

    func authorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus {
        authorizationStatusMap[type] ?? .notDetermined
    }

    func getRequestStatusForAuthorization(toShare typesToShare: Set<HKSampleType>, read typesToRead: Set<HKObjectType>, completion: @escaping @Sendable (HKAuthorizationRequestStatus, Error?) -> Void) {
        completion(authorizationRequestStatus, nil)
    }

    func executeSampleQuery(sampleType: HKSampleType, predicate: NSPredicate, limit: Int, sortDescriptors: [NSSortDescriptor], completion: @escaping @Sendable ([HKSample]?, Error?) -> Void) {
        completion([], nil)
    }

    func save(_ objects: [HKObject]) async throws {}
}

final class AuthorizationTrackingMockHealthStore: HealthStoreProtocol, @unchecked Sendable {
    var requestedShareTypes: Set<HKSampleType>?
    var requestedReadTypes: Set<HKObjectType>?
    var requestAuthorizationCallCount = 0

    func requestAuthorization(toShare typesToShare: Set<HKSampleType>?, read typesToRead: Set<HKObjectType>?, completion: @escaping @Sendable (Bool, Error?) -> Void) {
        requestedShareTypes = typesToShare
        requestedReadTypes = typesToRead
        requestAuthorizationCallCount += 1
        completion(true, nil)
    }

    func authorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus {
        .notDetermined
    }

    func getRequestStatusForAuthorization(toShare typesToShare: Set<HKSampleType>, read typesToRead: Set<HKObjectType>, completion: @escaping @Sendable (HKAuthorizationRequestStatus, Error?) -> Void) {
        completion(.shouldRequest, nil)
    }

    func executeSampleQuery(sampleType: HKSampleType, predicate: NSPredicate, limit: Int, sortDescriptors: [NSSortDescriptor], completion: @escaping @Sendable ([HKSample]?, Error?) -> Void) {
        completion([], nil)
    }

    func save(_ objects: [HKObject]) async throws {}
}

final class TrackingMockHealthStore: HealthStoreProtocol, @unchecked Sendable {
    var saveCallCount = 0
    var savedObjects: [[HKObject]] = []
    var shouldThrowOnSave: Error?

    func requestAuthorization(toShare typesToShare: Set<HKSampleType>?, read typesToRead: Set<HKObjectType>?, completion: @escaping @Sendable (Bool, Error?) -> Void) {
        completion(true, nil)
    }

    func authorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus {
        .sharingAuthorized
    }

    func getRequestStatusForAuthorization(toShare typesToShare: Set<HKSampleType>, read typesToRead: Set<HKObjectType>, completion: @escaping @Sendable (HKAuthorizationRequestStatus, Error?) -> Void) {
        completion(.unnecessary, nil)
    }

    func executeSampleQuery(sampleType: HKSampleType, predicate: NSPredicate, limit: Int, sortDescriptors: [NSSortDescriptor], completion: @escaping @Sendable ([HKSample]?, Error?) -> Void) {
        completion([], nil)
    }

    func save(_ objects: [HKObject]) async throws {
        if let error = shouldThrowOnSave {
            throw error
        }
        saveCallCount += 1
        savedObjects.append(objects)
    }
}

@Test
func healthSampleMapperMapsQuantitySample() {
    let quantityType = HKQuantityType(.stepCount)
    let quantity = HKQuantity(unit: .count(), doubleValue: 42)
    let start = Date().addingTimeInterval(-60)
    let end = Date()
    let sample = HKQuantitySample(type: quantityType, quantity: quantity, start: start, end: end)
    let dto = HealthSampleMapper.mapSample(sample, requestedType: .steps)
    #expect(dto?.value == 42)
    #expect(dto?.unit == "count")
}

@Test
func healthKitServiceReturnsOkWithEmptyResultsWhenNoData() async {
    let service = HealthKitService(store: MockHealthStore())
    let response = await service.fetchSamples(types: [.steps], startDate: Date().addingTimeInterval(-3600), endDate: Date(), limit: 1000, offset: 0)
    #expect(response.status == .ok)
    #expect(response.samples.isEmpty)
    #expect(response.returnedCount == 0)
}

@Test
func testRequestWriteAuthorization_contains7NutritionTypes() async throws {
    let mock = AuthorizationTrackingMockHealthStore()
    let service = HealthKitService(store: mock)

    let success = try await service.requestWriteAuthorization(for: HealthKitService.nutritionWriteTypes)
    let expectedShareTypes = Set(await MainActor.run {
        HealthKitService.nutritionWriteTypes.compactMap { $0.sampleType }
    })

    #expect(success)
    #expect(mock.requestAuthorizationCallCount == 1)
    #expect(mock.requestedShareTypes == expectedShareTypes)
    #expect(mock.requestedShareTypes?.count == 7)
    #expect(mock.requestedReadTypes?.isEmpty == true)
}

@Test
func testSaveSamples_callsSave() async throws {
    let mock = TrackingMockHealthStore()
    let service = HealthKitService(store: mock)
    let meal = NutritionWriteDTO(
        id: 1, name: "테스트 식사", eatenAt: Date(),
        calories: 500, proteinG: 30, carbsG: 50, fatG: 20,
        fiberG: 5, sodiumMg: 800, sugarG: 10
    )
    let response = try await service.saveSamples(HealthWriteRequest(meals: [meal]))
    #expect(mock.saveCallCount == 1)
    #expect(response.success == 1)
    #expect(response.failed == 0)
    #expect(response.errors.isEmpty)
}

@Test
func testSaveSamples_unauthorized() async throws {
    let mock = TrackingMockHealthStore()
    mock.shouldThrowOnSave = NSError(domain: HKErrorDomain, code: HKError.errorAuthorizationDenied.rawValue, userInfo: nil)
    let service = HealthKitService(store: mock)
    let meal = NutritionWriteDTO(
        id: 2, name: "실패 식사", eatenAt: Date(),
        calories: 300, proteinG: 20, carbsG: 40, fatG: 15,
        fiberG: 3, sodiumMg: 500, sugarG: 8
    )
    let response = try await service.saveSamples(HealthWriteRequest(meals: [meal]))
    #expect(response.success == 0)
    #expect(response.failed == 1)
    #expect(response.errors.count == 1)
}

@Test
func testSaveSamples_returnsCorrectCounts() async throws {
    let mock = TrackingMockHealthStore()
    let service = HealthKitService(store: mock)
    let meals = [
        NutritionWriteDTO(id: 3, name: "아침", eatenAt: Date(), calories: 400, proteinG: 25, carbsG: 45, fatG: 15, fiberG: 4, sodiumMg: 600, sugarG: 7),
        NutritionWriteDTO(id: 4, name: "점심", eatenAt: Date(), calories: 600, proteinG: 35, carbsG: 70, fatG: 20, fiberG: 6, sodiumMg: 900, sugarG: 12),
        NutritionWriteDTO(id: 5, name: "저녁", eatenAt: Date(), calories: 500, proteinG: 30, carbsG: 55, fatG: 18, fiberG: 5, sodiumMg: 700, sugarG: 9)
    ]
    let response = try await service.saveSamples(HealthWriteRequest(meals: meals))
    #expect(mock.saveCallCount == 3)
    #expect(response.success == 3)
    #expect(response.failed == 0)
}
