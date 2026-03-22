// Copyright 2026 Marcus Neves
// SPDX-License-Identifier: Apache-2.0

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Query(sort: \AuditEventRecord.timestamp, order: .reverse) private var auditEvents: [AuditEventRecord]

    var body: some View {
        NavigationStack {
            List {
                statusSection
                permissionsSection
                dataTypesSection
                auditSection
                settingsSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("HealthSync")
            .alert("Error", isPresented: Binding(get: { appState.lastError != nil }, set: { if !$0 { appState.lastError = nil } })) {
                Button("OK") { appState.lastError = nil }
            } message: {
                Text(appState.lastError ?? "")
            }
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private var statusSection: some View {
        Section("Status") {
            VStack(alignment: .leading, spacing: 4) {
                Text("Background Sync")
                    .font(.headline)
                if let lastExport = appState.syncConfiguration.lastExportAt {
                    Text("Last sync: \(lastExport.formatted())")
                        .foregroundColor(.secondary)
                } else {
                    Text("Last sync: Never")
                        .foregroundColor(.secondary)
                }
                Text("Status: Active")
                    .foregroundColor(.green)
            }
            .padding(.vertical, 4)

            LabeledContent("Version", value: appVersion)
            LabeledContent("Protected Data", value: appState.protectedDataAvailable ? "Available" : "Locked")
            LabeledContent("HealthKit", value: appState.healthAuthorizationStatus ? "Requested" : "Not Requested")
        }
    }

    private var permissionsSection: some View {
        Section("Permissions") {
            Button {
                HapticFeedback.impact(.medium)
                Task { await appState.requestHealthAuthorization() }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                    Text("Request HealthKit Access")
                }
            }
            .liquidGlassButtonStyle(.prominent)
        }
    }

    private var dataTypesSection: some View {
        Section("Shared Data Types") {
            ForEach(HealthDataType.allCases) { type in
                Toggle(type.displayName, isOn: Binding(
                    get: { appState.syncConfiguration.enabledTypes.contains(type) },
                    set: { newValue in appState.toggleType(type, enabled: newValue) }
                ))
            }
        }
    }

    private var auditSection: some View {
        Section("Audit") {
            if auditEvents.isEmpty {
                ContentUnavailableView {
                    Label("No Events", systemImage: "list.bullet.clipboard")
                } description: {
                    Text("No audit events yet.")
                }
                .listRowBackground(Color.clear)
            } else {
                ForEach(auditEvents.prefix(10), id: \.id) { event in
                    HStack {
                        Image(systemName: auditEventIcon(for: event.eventType))
                            .foregroundStyle(auditEventColor(for: event.eventType))
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(event.eventType)
                                .font(.subheadline)
                            Text(event.timestamp.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    private func auditEventIcon(for eventType: String) -> String {
        switch eventType {
        case let type where type.contains("auth"):
            return "person.badge.key.fill"
        case let type where type.contains("server"):
            return "server.rack"
        case let type where type.contains("health"):
            return "heart.fill"
        case let type where type.contains("revoke"):
            return "xmark.circle.fill"
        default:
            return "doc.text.fill"
        }
    }

    private func auditEventColor(for eventType: String) -> Color {
        switch eventType {
        case let type where type.contains("revoke"):
            return .red
        case let type where type.contains("auth"):
            return .blue
        case let type where type.contains("server"):
            return .green
        case let type where type.contains("health"):
            return .pink
        default:
            return .secondary
        }
    }

    private var settingsSection: some View {
        Section("Settings") {
            NavigationLink {
                PrivacyPolicyView()
            } label: {
                Label("Privacy Policy", systemImage: "hand.raised.fill")
            }

            NavigationLink {
                AboutView()
            } label: {
                Label("About", systemImage: "info.circle.fill")
            }
        }
    }
}

@MainActor
enum HapticFeedback {
    enum ImpactStyle {
        case light, medium, heavy, soft, rigid
    }

    enum NotificationType {
        case success, warning, error
    }

    static func impact(_ style: ImpactStyle) {}

    static func notification(_ type: NotificationType) {}

    static func selection() {}
}

#Preview {
    let schema = Schema([
        SyncConfiguration.self,
        PairedDevice.self,
        AuditEventRecord.self
    ])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: configuration)
    let state = AppState(modelContainer: container)
    return ContentView()
        .environment(state)
        .modelContainer(container)
}
