// Copyright 2026 Marcus Neves
// SPDX-License-Identifier: Apache-2.0

import Foundation
import HealthKit
import Observation
import os
import SwiftData
#if canImport(UIKit)
import UIKit
#else
final class UIApplicationShim {
    var isProtectedDataAvailable = true
}

enum UIApplication {
    static let shared = UIApplicationShim()
    static let protectedDataDidBecomeAvailableNotification = Notification.Name("UIApplication.protectedDataDidBecomeAvailableNotification")
    static let protectedDataWillBecomeUnavailableNotification = Notification.Name("UIApplication.protectedDataWillBecomeUnavailableNotification")
    static let didBecomeActiveNotification = Notification.Name("UIApplication.didBecomeActiveNotification")
}
#endif

@MainActor
@Observable
final class AppState {
    private let modelContainer: ModelContainer
    private let healthService = HealthKitService()
    private let auditService: AuditService
    private var notificationTask: Task<Void, Never>?

    var syncConfiguration: SyncConfiguration
    var lastError: String?
    var protectedDataAvailable: Bool = true
    var healthAuthorizationStatus: Bool = false

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.auditService = AuditService(modelContainer: modelContainer)

        let context = modelContainer.mainContext
        do {
            if let existing = try context.fetch(FetchDescriptor<SyncConfiguration>()).first {
                self.syncConfiguration = existing
            } else {
                let newConfig = SyncConfiguration()
                context.insert(newConfig)
                try context.save()
                self.syncConfiguration = newConfig
            }
        } catch {
            AppLoggers.app.error("Failed to load or create SyncConfiguration: \(error.localizedDescription, privacy: .public)")
            self.syncConfiguration = SyncConfiguration()
        }

        self.protectedDataAvailable = UIApplication.shared.isProtectedDataAvailable
    }

    func startNotificationObservers() {
        guard notificationTask == nil else { return }

        notificationTask = Task { [weak self] in
            guard let self else { return }

            await withTaskGroup(of: Void.self) { group in
                group.addTask { [weak self] in
                    for await _ in NotificationCenter.default.notifications(
                        named: UIApplication.protectedDataDidBecomeAvailableNotification
                    ) {
                        await self?.handleProtectedDataAvailable()
                    }
                }

                group.addTask { [weak self] in
                    for await _ in NotificationCenter.default.notifications(
                        named: UIApplication.protectedDataWillBecomeUnavailableNotification
                    ) {
                        await self?.handleProtectedDataUnavailable()
                    }
                }

                group.addTask { [weak self] in
                    for await _ in NotificationCenter.default.notifications(
                        named: UIApplication.didBecomeActiveNotification
                    ) {
                        await self?.handleAppDidBecomeActive()
                    }
                }
            }
        }
    }

    func requestHealthAuthorization() async {
        do {
            guard await healthService.isAvailable() else {
                healthAuthorizationStatus = false
                lastError = "Health data is unavailable on this device."
                await auditService.record(eventType: "auth.healthkit", details: ["status": "unavailable"])
                return
            }

            let dialogShown = try await healthService.requestAuthorization(for: syncConfiguration.enabledTypes)

            healthAuthorizationStatus = await healthService.hasRequestedAuthorization(for: syncConfiguration.enabledTypes)

            await auditService.record(eventType: "auth.healthkit", details: [
                "dialogShown": String(dialogShown),
                "requested": String(healthAuthorizationStatus)
            ])
        } catch {
            lastError = "HealthKit authorization failed: \(error.localizedDescription)"
        }
    }

    func toggleType(_ type: HealthDataType, enabled: Bool) {
        var types = syncConfiguration.enabledTypes
        if enabled {
            if !types.contains(type) {
                types.append(type)
            }
        } else {
            types.removeAll { $0 == type }
        }
        syncConfiguration.enabledTypes = types
        do {
            try modelContainer.mainContext.save()
        } catch {
            AppLoggers.app.error("Failed to save type toggle: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func handleProtectedDataAvailable() {
        protectedDataAvailable = true
    }

    private func handleProtectedDataUnavailable() {
        protectedDataAvailable = false
    }

    private func handleAppDidBecomeActive() {
        protectedDataAvailable = UIApplication.shared.isProtectedDataAvailable
        Task { await refreshHealthAuthorizationStatus() }
    }

    private func refreshHealthAuthorizationStatus() async {
        guard await healthService.isAvailable() else {
            healthAuthorizationStatus = false
            return
        }

        healthAuthorizationStatus = await healthService.hasRequestedAuthorization(for: syncConfiguration.enabledTypes)
    }
}
