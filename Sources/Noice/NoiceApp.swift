import SwiftUI

@main
struct NoiceApp: App {
    @StateObject private var state = AppState()

    var body: some Scene {
        MenuBarExtra {
            RootView()
                .environmentObject(state)
        } label: {
            Image(systemName: state.isPlaying ? "waveform" : "waveform.slash")
        }
        .menuBarExtraStyle(.window)
    }
}
