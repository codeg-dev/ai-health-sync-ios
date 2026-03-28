// Copyright 2026 Marcus Neves
// SPDX-License-Identifier: Apache-2.0

import HealthKit
import Foundation
import os

final class AnchorPersistence: AnchorPersistenceProtocol, @unchecked Sendable {
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func saveAnchor(_ anchor: HKQueryAnchor, for sampleType: HKSampleType) {
        let key = anchorKey(for: sampleType)
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: false)
            userDefaults.set(data, forKey: key)
        } catch {
            AppLoggers.sync.error("Failed to save anchor for \(sampleType.identifier): \(error.localizedDescription, privacy: .public)")
        }
    }
    
    func loadAnchor(for sampleType: HKSampleType) -> HKQueryAnchor? {
        let key = anchorKey(for: sampleType)
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        
        do {
            let anchor = try NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: data)
            return anchor
        } catch {
            AppLoggers.sync.error("Failed to load anchor for \(sampleType.identifier): \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
    
    func deleteAnchor(for sampleType: HKSampleType) {
        let key = anchorKey(for: sampleType)
        userDefaults.removeObject(forKey: key)
    }

    func resetAll() {
        userDefaults.dictionaryRepresentation().keys
            .filter { $0.hasPrefix("anchor.") || $0.hasPrefix("lastSync.") }
            .forEach { userDefaults.removeObject(forKey: $0) }
    }
    
    func saveLastSyncDate(_ date: Date, for sampleType: HKSampleType) {
        let key = lastSyncDateKey(for: sampleType)
        userDefaults.set(date, forKey: key)
    }
    
    func loadLastSyncDate(for sampleType: HKSampleType) -> Date? {
        let key = lastSyncDateKey(for: sampleType)
        return userDefaults.object(forKey: key) as? Date
    }
    
    private func anchorKey(for sampleType: HKSampleType) -> String {
        "anchor.\(sampleType.identifier)"
    }
    
    private func lastSyncDateKey(for sampleType: HKSampleType) -> String {
        "lastSync.\(sampleType.identifier)"
    }
}
