// Copyright 2026 Marcus Neves
// SPDX-License-Identifier: Apache-2.0

import os
import SwiftData
import SwiftUI

@main
struct iOS_Health_Sync_AppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    private let modelContainer: ModelContainer
    @State private var appState: AppState

    init() {
        UserDefaults.standard.register(defaults: [
            "serverURL": "http://100.87.151.20:8482"
        ])

        let schema = Schema(versionedSchema: SchemaV1.self)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        let container: ModelContainer
        do {
            container = try ModelContainer(
                for: schema,
                migrationPlan: HealthSyncMigrationPlan.self,
                configurations: configuration
            )
        } catch {
            AppLoggers.app.fault("ModelContainer init failed, recovering: \(error.localizedDescription, privacy: .public)")
            let storeURL = configuration.url
            try? FileManager.default.removeItem(at: storeURL)
            try? FileManager.default.removeItem(at: storeURL.deletingPathExtension().appendingPathExtension("store-wal"))
            try? FileManager.default.removeItem(at: storeURL.deletingPathExtension().appendingPathExtension("store-shm"))
            do {
                container = try ModelContainer(for: schema, configurations: configuration)
            } catch let recoveryError {
                AppLoggers.app.fault("Recovery failed, falling back to in-memory store: \(recoveryError.localizedDescription, privacy: .public)")
                // Last resort: in-memory store. SwiftData state is lost but app survives.
                // Critical sync state (anchors) is stored in UserDefaults separately.
                let memConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                do {
                    container = try ModelContainer(for: schema, configurations: memConfig)
                } catch let memError {
                    fatalError("Cannot create even in-memory ModelContainer: \(memError)")
                }
            }
        }

        self.modelContainer = container
        self._appState = State(initialValue: AppState(modelContainer: container))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .modelContainer(modelContainer)
                .task {
                    appState.startNotificationObservers()
                }
        }
    }
}
