// Copyright 2026 Marcus Neves
// SPDX-License-Identifier: Apache-2.0

import Foundation
import Testing
@testable import iOS_Health_Sync_App

final class MockPushSyncService: PushSyncServicing, @unchecked Sendable {
    var uploadCallCount = 0
    var lastDomain: String?
    var lastRecords: [HealthSampleDTO]?
    var resultToReturn: Result<PushResponse, Error> = .success(
        PushResponse(inserted: 1, skipped: 0, receivedAt: "2026-03-22T10:00:00Z")
    )

    func upload(domain: String, records: [HealthSampleDTO]) async throws -> PushResponse {
        uploadCallCount += 1
        lastDomain = domain
        lastRecords = records
        return try resultToReturn.get()
    }
}

@Test
func pushSyncServiceCanBeCreated() {
    let url = URL(string: "http://localhost:18810")!
    let _ = PushSyncService(serverURL: url, apiKey: "test-key")
}

@Test
func pushSyncServiceUsesUserDefaultsURL() {
    UserDefaults.standard.set("http://192.168.1.1:18810", forKey: "serverURL")
    defer { UserDefaults.standard.removeObject(forKey: "serverURL") }
    let _ = PushSyncService(apiKey: "test-key")
}

@Test
func mockUploadRecordsCallArguments() async throws {
    let mock = MockPushSyncService()
    let records = [makeHealthSampleDTO(type: "heartRate", value: 72.0)]

    let response = try await mock.upload(domain: "vitals", records: records)

    #expect(mock.uploadCallCount == 1)
    #expect(mock.lastDomain == "vitals")
    #expect(mock.lastRecords?.count == 1)
    #expect(mock.lastRecords?.first?.type == "heartRate")
    #expect(response.inserted == 1)
    #expect(response.skipped == 0)
}

@Test
func mockUploadPropagatesError() async {
    let mock = MockPushSyncService()
    mock.resultToReturn = .failure(URLError(.notConnectedToInternet))

    await #expect(throws: URLError.self) {
        try await mock.upload(domain: "vitals", records: [])
    }
    #expect(mock.uploadCallCount == 1)
}

@Test
func pushResponseDecodesFromJSON() throws {
    let json = """
    {"inserted": 3, "skipped": 1, "received_at": "2026-03-22T10:00:00Z"}
    """.data(using: .utf8)!

    let response = try JSONDecoder().decode(PushResponse.self, from: json)

    #expect(response.inserted == 3)
    #expect(response.skipped == 1)
    #expect(response.receivedAt == "2026-03-22T10:00:00Z")
}

@Test
func pushResponseEquality() {
    let a = PushResponse(inserted: 1, skipped: 0, receivedAt: "2026-03-22T10:00:00Z")
    let b = PushResponse(inserted: 1, skipped: 0, receivedAt: "2026-03-22T10:00:00Z")
    let c = PushResponse(inserted: 2, skipped: 0, receivedAt: "2026-03-22T10:00:00Z")

    #expect(a == b)
    #expect(a != c)
}

private func makeHealthSampleDTO(type: String, value: Double) -> HealthSampleDTO {
    HealthSampleDTO(
        id: UUID(),
        type: type,
        value: value,
        unit: "count/min",
        startDate: Date(timeIntervalSince1970: 1_742_641_200),
        endDate: Date(timeIntervalSince1970: 1_742_641_200),
        sourceName: "apple_health",
        metadata: nil
    )
}
