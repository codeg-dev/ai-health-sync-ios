// Copyright 2026 Marcus Neves
// SPDX-License-Identifier: Apache-2.0

import HealthKit
import Foundation

/// Protocol for persisting HKQueryAnchor and last sync dates.
/// Enables mock implementations for testing.
protocol AnchorPersistenceProtocol: Sendable {
    /// Save an anchor for a specific sample type.
    /// - Parameters:
    ///   - anchor: The HKQueryAnchor to persist
    ///   - sampleType: The HKSampleType associated with this anchor
    func saveAnchor(_ anchor: HKQueryAnchor, for sampleType: HKSampleType)
    
    /// Load an anchor for a specific sample type.
    /// - Parameters:
    ///   - sampleType: The HKSampleType to load anchor for
    /// - Returns: The persisted HKQueryAnchor, or nil if not found
    func loadAnchor(for sampleType: HKSampleType) -> HKQueryAnchor?
    
    /// Delete an anchor for a specific sample type.
    /// - Parameters:
    ///   - sampleType: The HKSampleType to delete anchor for
    func deleteAnchor(for sampleType: HKSampleType)
    
    /// Save the last sync date for a specific sample type.
    /// - Parameters:
    ///   - date: The sync date to persist
    ///   - sampleType: The HKSampleType associated with this sync date
    func saveLastSyncDate(_ date: Date, for sampleType: HKSampleType)
    
    /// Load the last sync date for a specific sample type.
    /// - Parameters:
    ///   - sampleType: The HKSampleType to load sync date for
    /// - Returns: The persisted sync date, or nil if not found
    func loadLastSyncDate(for sampleType: HKSampleType) -> Date?

    func resetAll()
}

extension AnchorPersistenceProtocol {
    func resetAll() {}
}
