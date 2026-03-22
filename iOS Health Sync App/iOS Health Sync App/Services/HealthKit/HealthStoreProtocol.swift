// Copyright 2026 Marcus Neves
// SPDX-License-Identifier: Apache-2.0

@preconcurrency import HealthKit

protocol HealthStoreProtocol: Sendable {
    func requestAuthorization(toShare typesToShare: Set<HKSampleType>?, read typesToRead: Set<HKObjectType>?, completion: @escaping @Sendable (Bool, Error?) -> Void)
    func authorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus
    func getRequestStatusForAuthorization(toShare typesToShare: Set<HKSampleType>, read typesToRead: Set<HKObjectType>, completion: @escaping @Sendable (HKAuthorizationRequestStatus, Error?) -> Void)
    func executeSampleQuery(sampleType: HKSampleType, predicate: NSPredicate, limit: Int, sortDescriptors: [NSSortDescriptor], completion: @escaping @Sendable ([HKSample]?, Error?) -> Void)
    func save(_ objects: [HKObject]) async throws
    func enableBackgroundDelivery(for type: HKObjectType, frequency: HKUpdateFrequency, withCompletion completion: @escaping @Sendable (Bool, Error?) -> Void)
    func executeObserverQuery(sampleType: HKSampleType, predicate: NSPredicate?, updateHandler: @escaping @Sendable (HKObserverQuery, @escaping HKObserverQueryCompletionHandler, Error?) -> Void) -> HKObserverQuery
    func executeAnchoredObjectQuery(sampleType: HKSampleType, predicate: NSPredicate?, anchor: HKQueryAnchor?, limit: Int, resultsHandler: @escaping @Sendable (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void)
    func stopQuery(_ query: HKQuery)
}

extension HealthStoreProtocol {
    func enableBackgroundDelivery(for type: HKObjectType, frequency: HKUpdateFrequency, withCompletion completion: @escaping @Sendable (Bool, Error?) -> Void) {
        if let store = self as? HKHealthStore {
            store.enableBackgroundDelivery(for: type, frequency: frequency, withCompletion: completion)
        } else {
            completion(true, nil)
        }
    }
    func executeObserverQuery(sampleType: HKSampleType, predicate: NSPredicate?, updateHandler: @escaping @Sendable (HKObserverQuery, @escaping HKObserverQueryCompletionHandler, Error?) -> Void) -> HKObserverQuery {
        HKObserverQuery(sampleType: sampleType, predicate: predicate) { _, _, _ in }
    }
    func executeAnchoredObjectQuery(sampleType: HKSampleType, predicate: NSPredicate?, anchor: HKQueryAnchor?, limit: Int, resultsHandler: @escaping @Sendable (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void) {
    }
    func stopQuery(_ query: HKQuery) {}
}

extension HKHealthStore: HealthStoreProtocol {
    func executeSampleQuery(sampleType: HKSampleType, predicate: NSPredicate, limit: Int, sortDescriptors: [NSSortDescriptor], completion: @escaping @Sendable ([HKSample]?, Error?) -> Void) {
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: limit, sortDescriptors: sortDescriptors) { _, samples, error in
            completion(samples, error)
        }
        execute(query)
    }

    func save(_ objects: [HKObject]) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            save(objects) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    func executeObserverQuery(sampleType: HKSampleType, predicate: NSPredicate?, updateHandler: @escaping @Sendable (HKObserverQuery, @escaping HKObserverQueryCompletionHandler, Error?) -> Void) -> HKObserverQuery {
        let query = HKObserverQuery(sampleType: sampleType, predicate: predicate, updateHandler: updateHandler)
        execute(query)
        return query
    }

    func executeAnchoredObjectQuery(sampleType: HKSampleType, predicate: NSPredicate?, anchor: HKQueryAnchor?, limit: Int, resultsHandler: @escaping @Sendable (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void) {
        let query = HKAnchoredObjectQuery(type: sampleType, predicate: predicate, anchor: anchor, limit: limit, resultsHandler: resultsHandler)
        execute(query)
    }

    func stopQuery(_ query: HKQuery) {
        stop(query)
    }
}
