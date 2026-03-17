// Copyright 2026 Marcus Neves
// SPDX-License-Identifier: Apache-2.0

@preconcurrency import HealthKit

protocol HealthStoreProtocol {
    func requestAuthorization(toShare typesToShare: Set<HKSampleType>?, read typesToRead: Set<HKObjectType>?, completion: @escaping @Sendable (Bool, Error?) -> Void)
    func authorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus
    func getRequestStatusForAuthorization(toShare typesToShare: Set<HKSampleType>, read typesToRead: Set<HKObjectType>, completion: @escaping @Sendable (HKAuthorizationRequestStatus, Error?) -> Void)
    func executeSampleQuery(sampleType: HKSampleType, predicate: NSPredicate, limit: Int, sortDescriptors: [NSSortDescriptor], completion: @escaping @Sendable ([HKSample]?, Error?) -> Void)
    func save(_ objects: [HKObject]) async throws
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
}
