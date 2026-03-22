// Copyright 2026 Marcus Neves
// SPDX-License-Identifier: Apache-2.0

import Foundation
import UIKit

actor PushSyncService: NSObject, URLSessionDataDelegate, PushSyncServicing {
    static let sessionIdentifier = "com.vitalery.healthkit.push"

    private let serverURL: URL
    private let apiKey: String
    private var session: URLSession!
    private var pendingCompletions: [Int: CheckedContinuation<PushResponse, Error>] = [:]
    private var accumulatedData: [Int: Data] = [:]

    init(serverURL: URL, apiKey: String) {
        self.serverURL = serverURL
        self.apiKey = apiKey
        super.init()
        let config = URLSessionConfiguration.background(withIdentifier: Self.sessionIdentifier)
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }

    init(apiKey: String) {
        let rawURL = UserDefaults.standard.string(forKey: "serverURL") ?? "http://100.95.234.69:18810"
        self.serverURL = URL(string: rawURL) ?? URL(string: "http://100.95.234.69:18810")!
        self.apiKey = apiKey
        super.init()
        let config = URLSessionConfiguration.background(withIdentifier: Self.sessionIdentifier)
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }

    func upload(domain: String, records: [HealthSampleDTO]) async throws -> PushResponse {
        let endpoint = serverURL.appendingPathComponent("ahk/push")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let body = AhkPushRequest(domain: domain, records: records.map(AhkPushRecord.init))
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let bodyData = try encoder.encode(body)

        return try await withCheckedThrowingContinuation { continuation in
            let task = session.uploadTask(with: request, from: bodyData)
            pendingCompletions[task.taskIdentifier] = continuation
            accumulatedData[task.taskIdentifier] = Data()
            task.resume()
        }
    }

    private func appendData(_ data: Data, for taskID: Int) {
        accumulatedData[taskID, default: Data()].append(data)
    }

    private func completeTask(_ taskID: Int, error: Error?) {
        guard let continuation = pendingCompletions.removeValue(forKey: taskID) else { return }
        let data = accumulatedData.removeValue(forKey: taskID) ?? Data()

        if let error {
            continuation.resume(throwing: error)
            return
        }

        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(PushResponse.self, from: data)
            continuation.resume(returning: response)
        } catch {
            continuation.resume(throwing: error)
        }
    }

    nonisolated func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {
        Task { await self.appendData(data, for: dataTask.taskIdentifier) }
    }

    nonisolated func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        Task { await self.completeTask(task.taskIdentifier, error: error) }
    }

    nonisolated func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        let identifier = session.configuration.identifier ?? ""
        Task { @MainActor in
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
               let handler = appDelegate.backgroundSessionCompletionHandlers.removeValue(forKey: identifier) {
                handler()
            }
        }
    }
}

private struct AhkPushRecord: Encodable {
    let metricType: String
    let value: Double
    let unit: String
    let recordedAt: Date
    let source: String

    enum CodingKeys: String, CodingKey {
        case metricType = "metric_type"
        case value
        case unit
        case recordedAt = "recorded_at"
        case source
    }

    init(from dto: HealthSampleDTO) {
        self.metricType = dto.type
        self.value = dto.value
        self.unit = dto.unit
        self.recordedAt = dto.startDate
        self.source = dto.sourceName
    }
}

private struct AhkPushRequest: Encodable {
    let domain: String
    let records: [AhkPushRecord]
}
