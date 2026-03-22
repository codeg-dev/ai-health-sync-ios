// Copyright 2026 Marcus Neves
// SPDX-License-Identifier: Apache-2.0

import Foundation

struct PushResponse: Codable, Sendable, Equatable {
    let inserted: Int
    let skipped: Int
    let receivedAt: String

    enum CodingKeys: String, CodingKey {
        case inserted
        case skipped
        case receivedAt = "received_at"
    }
}

enum PushSyncError: Error, Equatable {
    case invalidServerURL
}

protocol PushSyncServicing: Sendable {
    func upload(domain: String, records: [HealthSampleDTO]) async throws -> PushResponse
}
