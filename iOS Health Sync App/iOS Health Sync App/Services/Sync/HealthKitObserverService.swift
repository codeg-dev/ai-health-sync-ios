// Copyright 2026 Marcus Neves
// SPDX-License-Identifier: Apache-2.0

@preconcurrency import HealthKit
import Foundation
import os

actor HealthKitObserverService {
    private let healthStore: HealthStoreProtocol
    private let pushService: PushSyncServicing
    private let anchorPersistence: AnchorPersistenceProtocol
    private var activeQueries: [String: HKObserverQuery] = [:]

    static let defaultBatchLimit = 1000

    nonisolated private static let identifierToDataTypeMap: [String: HealthDataType] = {
        var map: [String: HealthDataType] = [:]
        for type in HealthDataType.allCases {
            if let sampleType = type.sampleType, map[sampleType.identifier] == nil {
                map[sampleType.identifier] = type
            }
        }
        return map
    }()

    init(healthStore: HealthStoreProtocol, pushService: PushSyncServicing, anchorPersistence: AnchorPersistenceProtocol) {
        self.healthStore = healthStore
        self.pushService = pushService
        self.anchorPersistence = anchorPersistence
    }

    func startObserving(types: [HKSampleType]) async throws {
        for type in types {
            try await registerObserver(for: type)
        }
    }

    func stopObserving() {
        for (_, query) in activeQueries {
            healthStore.stopQuery(query)
        }
        activeQueries.removeAll()
    }

    func handleObserverUpdate(for sampleType: HKSampleType) async {
        let anchor = anchorPersistence.loadAnchor(for: sampleType)
        await fetchAndUpload(sampleType: sampleType, anchor: anchor)
    }

    private func registerObserver(for sampleType: HKSampleType) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            healthStore.enableBackgroundDelivery(for: sampleType, frequency: .immediate) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }

        let query = healthStore.executeObserverQuery(sampleType: sampleType, predicate: nil) { [weak self] _, completionHandler, error in
            defer { completionHandler() }
            guard let self, error == nil else { return }
            Task {
                await self.handleObserverUpdate(for: sampleType)
            }
        }
        activeQueries[sampleType.identifier] = query
    }

    private func fetchAndUpload(sampleType: HKSampleType, anchor: HKQueryAnchor?) async {
        let result = await withCheckedContinuation { (continuation: CheckedContinuation<QueryResult, Never>) in
            healthStore.executeAnchoredObjectQuery(
                sampleType: sampleType,
                predicate: nil,
                anchor: anchor,
                limit: Self.defaultBatchLimit
            ) { _, newSamples, _, newAnchor, error in
                continuation.resume(returning: QueryResult(
                    samples: newSamples ?? [],
                    anchor: newAnchor,
                    error: error
                ))
            }
        }

        if let error = result.error {
            AppLoggers.sync.error("AnchoredObjectQuery failed: \(error.localizedDescription, privacy: .public)")
            return
        }

        guard let newAnchor = result.anchor else { return }

        let dtos = result.samples.compactMap { sample -> HealthSampleDTO? in
            guard let dataType = Self.identifierToDataTypeMap[sample.sampleType.identifier] else { return nil }
            return HealthSampleMapper.mapSample(sample, requestedType: dataType)
        }

        if dtos.isEmpty {
            anchorPersistence.saveAnchor(newAnchor, for: sampleType)
            return
        }

        do {
            _ = try await pushService.upload(domain: "vitals", records: dtos)
            anchorPersistence.saveAnchor(newAnchor, for: sampleType)
            if result.samples.count >= Self.defaultBatchLimit {
                await fetchAndUpload(sampleType: sampleType, anchor: newAnchor)
            }
        } catch {
            AppLoggers.sync.error("Upload failed for \(sampleType.identifier, privacy: .public): \(error.localizedDescription, privacy: .public)")
        }
    }
}

private struct QueryResult: @unchecked Sendable {
    let samples: [HKSample]
    let anchor: HKQueryAnchor?
    let error: Error?
}
