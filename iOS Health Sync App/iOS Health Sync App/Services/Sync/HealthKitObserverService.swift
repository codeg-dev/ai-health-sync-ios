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

    private var pendingTypes: [HKSampleType] = []
    private var isProcessing = false

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
            do {
                try await registerObserver(for: type)
            } catch {
                AppLoggers.sync.warning("registerObserver skipped for \(type.identifier, privacy: .public): \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    func stopObserving() {
        for (_, query) in activeQueries {
            healthStore.stopQuery(query)
        }
        activeQueries.removeAll()
        pendingTypes.removeAll()
    }

    func resetAndResync() {
        anchorPersistence.resetAll()
        pendingTypes.removeAll()
        let activeIdentifiers = Set(activeQueries.keys)
        var seen = Set<String>()
        for dataType in HealthDataType.allCases {
            guard let sampleType = dataType.sampleType,
                  activeIdentifiers.contains(sampleType.identifier),
                  seen.insert(sampleType.identifier).inserted else { continue }
            pendingTypes.append(sampleType)
        }
        guard !isProcessing else { return }
        Task { await drainQueue() }
    }

    func handleObserverUpdate(for sampleType: HKSampleType) async {
        let id = sampleType.identifier
        guard !pendingTypes.contains(where: { $0.identifier == id }) else { return }
        pendingTypes.append(sampleType)
        guard !isProcessing else { return }
        await drainQueue()
    }

    private func drainQueue() async {
        isProcessing = true
        while let next = pendingTypes.first {
            pendingTypes.removeFirst()
            let anchor = anchorPersistence.loadAnchor(for: next)
            await fetchAndUpload(sampleType: next, anchor: anchor)
        }
        isProcessing = false
    }

    private func registerObserver(for sampleType: HKSampleType) async throws {
        if sampleType is HKWorkoutType {
            AppLoggers.sync.info("Skipping background delivery for HKWorkoutType (not supported)")
        } else {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                healthStore.enableBackgroundDelivery(for: sampleType, frequency: .immediate) { _, error in
                    if let error {
                        AppLoggers.sync.warning("enableBackgroundDelivery failed for \(sampleType.identifier, privacy: .public): \(error.localizedDescription, privacy: .public)")
                    }
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
        var currentAnchor = anchor

        while true {
            let result = await withCheckedContinuation { (continuation: CheckedContinuation<QueryResult, Never>) in
                healthStore.executeAnchoredObjectQuery(
                    sampleType: sampleType,
                    predicate: nil,
                    anchor: currentAnchor,
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
                guard result.samples.count >= Self.defaultBatchLimit else { return }
                currentAnchor = newAnchor
            } catch {
                AppLoggers.sync.error("Upload failed for \(sampleType.identifier, privacy: .public): \(error.localizedDescription, privacy: .public)")
                return
            }
        }
    }
}

private struct QueryResult: @unchecked Sendable {
    let samples: [HKSample]
    let anchor: HKQueryAnchor?
    let error: Error?
}
