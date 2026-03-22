// Copyright 2026 Marcus Neves
// SPDX-License-Identifier: Apache-2.0

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    /// Background URLSession completion handlers
    /// Key: URLSession identifier, Value: completion handler
    var backgroundSessionCompletionHandlers: [String: () -> Void] = [:]

    /// Handle background URLSession events
    /// Called when background URLSession completes downloads/uploads
    func application(
        _ application: UIApplication,
        handleEventsForBackgroundURLSession identifier: String,
        completionHandler: @escaping () -> Void
    ) {
        backgroundSessionCompletionHandlers[identifier] = completionHandler
    }
}
