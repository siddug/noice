import Foundation
import ServiceManagement

/// Thin wrapper over SMAppService for the "launch at login" toggle (macOS 13+).
enum LaunchAtLogin {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func set(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("Noice: launch-at-login toggle failed: \(error)")
        }
    }
}
