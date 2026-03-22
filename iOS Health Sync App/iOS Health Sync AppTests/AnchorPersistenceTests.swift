// Copyright 2026 Marcus Neves
// SPDX-License-Identifier: Apache-2.0

import HealthKit
import Testing
@testable import iOS_Health_Sync_App

struct AnchorPersistenceTests {
    
    // MARK: - Mock Implementation for Testing
    
    struct InMemoryAnchorPersistence: AnchorPersistenceProtocol {
        private var anchors: [String: HKQueryAnchor] = [:]
        private var syncDates: [String: Date] = [:]
        
        mutating func saveAnchor(_ anchor: HKQueryAnchor, for sampleType: HKSampleType) {
            anchors[sampleType.identifier] = anchor
        }
        
        func loadAnchor(for sampleType: HKSampleType) -> HKQueryAnchor? {
            anchors[sampleType.identifier]
        }
        
        mutating func deleteAnchor(for sampleType: HKSampleType) {
            anchors.removeValue(forKey: sampleType.identifier)
        }
        
        mutating func saveLastSyncDate(_ date: Date, for sampleType: HKSampleType) {
            syncDates[sampleType.identifier] = date
        }
        
        func loadLastSyncDate(for sampleType: HKSampleType) -> Date? {
            syncDates[sampleType.identifier]
        }
    }
    
    // MARK: - Tests
    
    @Test("Save and load anchor roundtrip")
    func testAnchorRoundtrip() throws {
        let userDefaults = UserDefaults(suiteName: "test.anchor.roundtrip")!
        let persistence = AnchorPersistence(userDefaults: userDefaults)
        
        let sampleType = HKQuantityType(.stepCount)
        let originalAnchor = HKQueryAnchor(byAdding: .day, value: -1, to: Date())
        
        persistence.saveAnchor(originalAnchor, for: sampleType)
        let loadedAnchor = persistence.loadAnchor(for: sampleType)
        
        #expect(loadedAnchor != nil)
    }
    
    @Test("Load non-existent anchor returns nil")
    func testLoadNonExistentAnchor() {
        let userDefaults = UserDefaults(suiteName: "test.anchor.nonexistent")!
        let persistence = AnchorPersistence(userDefaults: userDefaults)
        
        let sampleType = HKQuantityType(.stepCount)
        let loadedAnchor = persistence.loadAnchor(for: sampleType)
        
        #expect(loadedAnchor == nil)
    }
    
    @Test("Different sample types have independent anchors")
    func testIndependentAnchors() throws {
        let userDefaults = UserDefaults(suiteName: "test.anchor.independent")!
        let persistence = AnchorPersistence(userDefaults: userDefaults)
        
        let stepsType = HKQuantityType(.stepCount)
        let heartRateType = HKQuantityType(.heartRate)
        
        let stepsAnchor = HKQueryAnchor(byAdding: .day, value: -1, to: Date())
        let heartRateAnchor = HKQueryAnchor(byAdding: .day, value: -2, to: Date())
        
        persistence.saveAnchor(stepsAnchor, for: stepsType)
        persistence.saveAnchor(heartRateAnchor, for: heartRateType)
        
        let loadedStepsAnchor = persistence.loadAnchor(for: stepsType)
        let loadedHeartRateAnchor = persistence.loadAnchor(for: heartRateType)
        
        #expect(loadedStepsAnchor != nil)
        #expect(loadedHeartRateAnchor != nil)
    }
    
    @Test("Delete anchor removes it from storage")
    func testDeleteAnchor() throws {
        let userDefaults = UserDefaults(suiteName: "test.anchor.delete")!
        let persistence = AnchorPersistence(userDefaults: userDefaults)
        
        let sampleType = HKQuantityType(.stepCount)
        let anchor = HKQueryAnchor(byAdding: .day, value: -1, to: Date())
        
        persistence.saveAnchor(anchor, for: sampleType)
        #expect(persistence.loadAnchor(for: sampleType) != nil)
        
        persistence.deleteAnchor(for: sampleType)
        #expect(persistence.loadAnchor(for: sampleType) == nil)
    }
    
    @Test("Save and load last sync date roundtrip")
    func testLastSyncDateRoundtrip() {
        let userDefaults = UserDefaults(suiteName: "test.sync.date.roundtrip")!
        let persistence = AnchorPersistence(userDefaults: userDefaults)
        
        let sampleType = HKQuantityType(.stepCount)
        let originalDate = Date()
        
        persistence.saveLastSyncDate(originalDate, for: sampleType)
        let loadedDate = persistence.loadLastSyncDate(for: sampleType)
        
        #expect(loadedDate != nil)
        #expect(abs(loadedDate!.timeIntervalSince(originalDate)) < 1.0)
    }
    
    @Test("Load non-existent sync date returns nil")
    func testLoadNonExistentSyncDate() {
        let userDefaults = UserDefaults(suiteName: "test.sync.date.nonexistent")!
        let persistence = AnchorPersistence(userDefaults: userDefaults)
        
        let sampleType = HKQuantityType(.stepCount)
        let loadedDate = persistence.loadLastSyncDate(for: sampleType)
        
        #expect(loadedDate == nil)
    }
    
    @Test("Different sample types have independent sync dates")
    func testIndependentSyncDates() {
        let userDefaults = UserDefaults(suiteName: "test.sync.date.independent")!
        let persistence = AnchorPersistence(userDefaults: userDefaults)
        
        let stepsType = HKQuantityType(.stepCount)
        let heartRateType = HKQuantityType(.heartRate)
        
        let stepsDate = Date()
        let heartRateDate = Date().addingTimeInterval(-3600)
        
        persistence.saveLastSyncDate(stepsDate, for: stepsType)
        persistence.saveLastSyncDate(heartRateDate, for: heartRateType)
        
        let loadedStepsDate = persistence.loadLastSyncDate(for: stepsType)
        let loadedHeartRateDate = persistence.loadLastSyncDate(for: heartRateType)
        
        #expect(loadedStepsDate != nil)
        #expect(loadedHeartRateDate != nil)
        #expect(abs(loadedStepsDate!.timeIntervalSince(stepsDate)) < 1.0)
        #expect(abs(loadedHeartRateDate!.timeIntervalSince(heartRateDate)) < 1.0)
    }
    
    @Test("InMemoryAnchorPersistence mock works correctly")
    func testInMemoryMock() {
        var mock = InMemoryAnchorPersistence()
        
        let sampleType = HKQuantityType(.stepCount)
        let anchor = HKQueryAnchor(byAdding: .day, value: -1, to: Date())
        let syncDate = Date()
        
        mock.saveAnchor(anchor, for: sampleType)
        mock.saveLastSyncDate(syncDate, for: sampleType)
        
        #expect(mock.loadAnchor(for: sampleType) != nil)
        #expect(mock.loadLastSyncDate(for: sampleType) != nil)
        
        mock.deleteAnchor(for: sampleType)
        #expect(mock.loadAnchor(for: sampleType) == nil)
    }
}
