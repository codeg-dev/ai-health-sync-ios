// Copyright 2026 Marcus Neves
// SPDX-License-Identifier: Apache-2.0

@preconcurrency import HealthKit
import UIKit
import os

class AppDelegate: NSObject, UIApplicationDelegate {
    /// Background URLSession completion handlers
    /// Key: URLSession identifier, Value: completion handler
    var backgroundSessionCompletionHandlers: [String: () -> Void] = [:]

    var healthStore: HealthStoreProtocol = HKHealthStore()
    var pushService: PushSyncServicing?
    var anchorPersistence: AnchorPersistenceProtocol = AnchorPersistence()
    var isHealthDataAvailable: () -> Bool = { HKHealthStore.isHealthDataAvailable() }
    private(set) var observerService: HealthKitObserverService?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        Task {
            await setupHealthKitSync()
        }
        return true
    }

    /// Handle background URLSession events
    /// Called when background URLSession completes downloads/uploads
    func application(
        _ application: UIApplication,
        handleEventsForBackgroundURLSession identifier: String,
        completionHandler: @escaping () -> Void
    ) {
        backgroundSessionCompletionHandlers[identifier] = completionHandler
    }

    func setupHealthKitSync() async {
        guard isHealthDataAvailable() else { return }

        let allSampleTypes = HealthDataType.allCases.compactMap { $0.sampleType }
        guard !allSampleTypes.isEmpty else { return }

        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                let readTypes = Set(allSampleTypes.map { $0 as HKObjectType })
                healthStore.requestAuthorization(toShare: [], read: readTypes) { _, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
            }
        } catch {
            AppLoggers.sync.warning("HealthKit authorization failed: \(error.localizedDescription, privacy: .public)")
            return
        }

        let effectivePushService: PushSyncServicing
        if let injected = pushService {
            effectivePushService = injected
        } else {
            let apiKey = UserDefaults.standard.string(forKey: "pushAPIKey") ?? ""
            do {
                effectivePushService = try PushSyncService(apiKey: apiKey)
            } catch {
                AppLoggers.sync.error("Invalid server URL — configure serverURL in Settings: \(error.localizedDescription, privacy: .public)")
                return
            }
        }

        let svc = HealthKitObserverService(
            healthStore: healthStore,
            pushService: effectivePushService,
            anchorPersistence: anchorPersistence
        )
        observerService = svc

        do {
            try await svc.startObserving(types: allSampleTypes)
        } catch {
            AppLoggers.sync.error("Observer registration failed: \(error.localizedDescription, privacy: .public)")
            return
        }

        for type in allSampleTypes {
            await svc.handleObserverUpdate(for: type)
        }
    }
}
