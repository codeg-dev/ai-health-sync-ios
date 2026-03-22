// Copyright 2026 Marcus Neves
// SPDX-License-Identifier: Apache-2.0

@preconcurrency import HealthKit
import Testing
@testable import iOS_Health_Sync_App

final class AppDelegateTestHealthStore: HealthStoreProtocol, @unchecked Sendable {
    var enableBackgroundDeliveryCallCount = 0
    var anchoredQueryCallCount = 0

    func requestAuthorization(toShare: Set<HKSampleType>?, read: Set<HKObjectType>?, completion: @escaping @Sendable (Bool, Error?) -> Void) {
        completion(true, nil)
    }
    func authorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus { .notDetermined }
    func getRequestStatusForAuthorization(toShare: Set<HKSampleType>, read: Set<HKObjectType>, completion: @escaping @Sendable (HKAuthorizationRequestStatus, Error?) -> Void) {
        completion(.shouldRequest, nil)
    }
    func executeSampleQuery(sampleType: HKSampleType, predicate: NSPredicate, limit: Int, sortDescriptors: [NSSortDescriptor], completion: @escaping @Sendable ([HKSample]?, Error?) -> Void) {
        completion([], nil)
    }
    func save(_ objects: [HKObject]) async throws {}
    func enableBackgroundDelivery(for type: HKObjectType, frequency: HKUpdateFrequency, withCompletion completion: @escaping @Sendable (Bool, Error?) -> Void) {
        enableBackgroundDeliveryCallCount += 1
        completion(true, nil)
    }
    func executeObserverQuery(sampleType: HKSampleType, predicate: NSPredicate?, updateHandler: @escaping @Sendable (HKObserverQuery, @escaping HKObserverQueryCompletionHandler, Error?) -> Void) -> HKObserverQuery {
        HKObserverQuery(sampleType: sampleType, predicate: predicate) { _, _, _ in }
    }
    func executeAnchoredObjectQuery(sampleType: HKSampleType, predicate: NSPredicate?, anchor: HKQueryAnchor?, limit: Int, resultsHandler: @escaping @Sendable (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void) {
        anchoredQueryCallCount += 1
        let dummyQuery = HKAnchoredObjectQuery(type: sampleType, predicate: predicate, anchor: anchor, limit: limit) { _, _, _, _, _ in }
        resultsHandler(dummyQuery, nil, nil, HKQueryAnchor(fromValue: 0), nil)
    }
    func stopQuery(_ query: HKQuery) {}
}

@Test("앱 시작 시 startObserving 호출 확인 — enableBackgroundDelivery 최소 1회 호출")
@MainActor
func testAppLaunchCallsStartObserving() async throws {
    let mockStore = AppDelegateTestHealthStore()
    let appDelegate = AppDelegate()
    appDelegate.healthStore = mockStore
    appDelegate.pushService = MockPushSyncService()
    appDelegate.anchorPersistence = MockAnchorPersistenceForObserver()
    appDelegate.isHealthDataAvailable = { true }

    await appDelegate.setupHealthKitSync()

    #expect(mockStore.enableBackgroundDeliveryCallCount > 0)
}

@Test("앱 시작 시 catchup 동기화 실행 확인 — executeAnchoredObjectQuery 최소 1회 호출")
@MainActor
func testAppLaunchRunsCatchupSync() async throws {
    let mockStore = AppDelegateTestHealthStore()
    let appDelegate = AppDelegate()
    appDelegate.healthStore = mockStore
    appDelegate.pushService = MockPushSyncService()
    appDelegate.anchorPersistence = MockAnchorPersistenceForObserver()
    appDelegate.isHealthDataAvailable = { true }

    await appDelegate.setupHealthKitSync()

    #expect(mockStore.anchoredQueryCallCount > 0)
}

@Test("HealthKit 미지원 환경에서 setupHealthKitSync graceful 처리 — observerService nil")
@MainActor
func testSetupHealthKitSyncGracefulWhenUnavailable() async {
    let appDelegate = AppDelegate()
    appDelegate.isHealthDataAvailable = { false }

    await appDelegate.setupHealthKitSync()

    #expect(appDelegate.observerService == nil)
}

@Test("권한 요청 실패 시 observerService 미설정 — graceful 처리")
@MainActor
func testAuthorizationFailureDoesNotCrash() async {
    final class FailingAuthHealthStore: HealthStoreProtocol, @unchecked Sendable {
        func requestAuthorization(toShare: Set<HKSampleType>?, read: Set<HKObjectType>?, completion: @escaping @Sendable (Bool, Error?) -> Void) {
            completion(false, NSError(domain: HKErrorDomain, code: HKError.errorAuthorizationDenied.rawValue))
        }
        func authorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus { .sharingDenied }
        func getRequestStatusForAuthorization(toShare: Set<HKSampleType>, read: Set<HKObjectType>, completion: @escaping @Sendable (HKAuthorizationRequestStatus, Error?) -> Void) {
            completion(.shouldRequest, nil)
        }
        func executeSampleQuery(sampleType: HKSampleType, predicate: NSPredicate, limit: Int, sortDescriptors: [NSSortDescriptor], completion: @escaping @Sendable ([HKSample]?, Error?) -> Void) {
            completion([], nil)
        }
        func save(_ objects: [HKObject]) async throws {}
    }

    let appDelegate = AppDelegate()
    appDelegate.healthStore = FailingAuthHealthStore()
    appDelegate.isHealthDataAvailable = { true }

    await appDelegate.setupHealthKitSync()

    #expect(appDelegate.observerService == nil)
}
