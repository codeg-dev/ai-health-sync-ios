// Copyright 2026 Marcus Neves
// SPDX-License-Identifier: Apache-2.0

@preconcurrency import HealthKit
import Testing
@testable import iOS_Health_Sync_App

final class ObserverTrackingMockHealthStore: HealthStoreProtocol, @unchecked Sendable {
    var enableBackgroundDeliveryCallCount = 0
    var lastObserverUpdateHandler: (@Sendable (HKObserverQuery, @escaping HKObserverQueryCompletionHandler, Error?) -> Void)?
    var anchoredQuerySamples: [HKSample] = []
    var anchoredQueryAnchor: HKQueryAnchor?
    var anchoredQueryError: Error?

    func requestAuthorization(toShare typesToShare: Set<HKSampleType>?, read typesToRead: Set<HKObjectType>?, completion: @escaping @Sendable (Bool, Error?) -> Void) {
        completion(true, nil)
    }
    func authorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus { .notDetermined }
    func getRequestStatusForAuthorization(toShare typesToShare: Set<HKSampleType>, read typesToRead: Set<HKObjectType>, completion: @escaping @Sendable (HKAuthorizationRequestStatus, Error?) -> Void) {
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
        lastObserverUpdateHandler = updateHandler
        return HKObserverQuery(sampleType: sampleType, predicate: predicate) { _, _, _ in }
    }

    func executeAnchoredObjectQuery(sampleType: HKSampleType, predicate: NSPredicate?, anchor: HKQueryAnchor?, limit: Int, resultsHandler: @escaping @Sendable (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void) {
        let dummyQuery = HKAnchoredObjectQuery(type: sampleType, predicate: predicate, anchor: anchor, limit: limit) { _, _, _, _, _ in }
        let samples: [HKSample]? = anchoredQuerySamples.isEmpty ? nil : anchoredQuerySamples
        resultsHandler(dummyQuery, samples, nil, anchoredQueryAnchor, anchoredQueryError)
    }

    func stopQuery(_ query: HKQuery) {}
}

final class MockAnchorPersistenceForObserver: AnchorPersistenceProtocol, @unchecked Sendable {
    var saveAnchorCallCount = 0
    private var anchors: [String: HKQueryAnchor] = [:]

    func saveAnchor(_ anchor: HKQueryAnchor, for sampleType: HKSampleType) {
        saveAnchorCallCount += 1
        anchors[sampleType.identifier] = anchor
    }
    func loadAnchor(for sampleType: HKSampleType) -> HKQueryAnchor? { anchors[sampleType.identifier] }
    func deleteAnchor(for sampleType: HKSampleType) { anchors.removeValue(forKey: sampleType.identifier) }
    func saveLastSyncDate(_ date: Date, for sampleType: HKSampleType) {}
    func loadLastSyncDate(for sampleType: HKSampleType) -> Date? { nil }
}

@Test("Observer 등록 시 enableBackgroundDelivery 호출 확인")
func testStartObservingCallsEnableBackgroundDelivery() async throws {
    let mockStore = ObserverTrackingMockHealthStore()
    let service = HealthKitObserverService(
        healthStore: mockStore,
        pushService: MockPushSyncService(),
        anchorPersistence: MockAnchorPersistenceForObserver()
    )
    try await service.startObserving(types: [HKQuantityType(.heartRate)])
    #expect(mockStore.enableBackgroundDeliveryCallCount == 1)
}

@Test("completionHandler가 defer로 호출되는지 확인")
func testObserverCompletionHandlerCalledViaDefer() async throws {
    let mockStore = ObserverTrackingMockHealthStore()
    let service = HealthKitObserverService(
        healthStore: mockStore,
        pushService: MockPushSyncService(),
        anchorPersistence: MockAnchorPersistenceForObserver()
    )
    try await service.startObserving(types: [HKQuantityType(.heartRate)])

    var completionHandlerCalled = false
    let dummyQuery = HKObserverQuery(sampleType: HKQuantityType(.heartRate), predicate: nil) { _, _, _ in }
    mockStore.lastObserverUpdateHandler?(dummyQuery, { completionHandlerCalled = true }, nil)
    #expect(completionHandlerCalled)
}

@Test("AnchoredObjectQuery 성공 시 Anchor 저장 확인")
func testAnchoredQuerySuccessSavesAnchor() async {
    let mockStore = ObserverTrackingMockHealthStore()
    let mockPersistence = MockAnchorPersistenceForObserver()
    mockStore.anchoredQueryAnchor = HKQueryAnchor(fromValue: 0)
    let service = HealthKitObserverService(
        healthStore: mockStore,
        pushService: MockPushSyncService(),
        anchorPersistence: mockPersistence
    )
    await service.handleObserverUpdate(for: HKQuantityType(.heartRate))
    #expect(mockPersistence.saveAnchorCallCount == 1)
}

@Test("AnchoredObjectQuery 실패 시 Anchor 미저장 확인")
func testAnchoredQueryErrorDoesNotSaveAnchor() async {
    let mockStore = ObserverTrackingMockHealthStore()
    let mockPersistence = MockAnchorPersistenceForObserver()
    mockStore.anchoredQueryError = NSError(domain: HKErrorDomain, code: HKError.errorAuthorizationDenied.rawValue)
    let service = HealthKitObserverService(
        healthStore: mockStore,
        pushService: MockPushSyncService(),
        anchorPersistence: mockPersistence
    )
    await service.handleObserverUpdate(for: HKQuantityType(.heartRate))
    #expect(mockPersistence.saveAnchorCallCount == 0)
}
