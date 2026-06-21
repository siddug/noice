import SwiftUI

/// The menu-bar popover: title bar, spatial canvas, palette and controls.
struct RootView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            Divider().opacity(0.4)
            CanvasView()
                .frame(height: 300)
                .padding(.vertical, 8)
            PaletteView()
            Divider().opacity(0.4)
            ControlsView()
        }
        .frame(width: 360)
        .background(.ultraThinMaterial)
    }
}

private struct HeaderView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        HStack {
            Image(systemName: "waveform")
                .foregroundStyle(.tint)
            Text("Noice")
                .font(.headline)
            Spacer()
            if !state.layers.isEmpty {
                Button {
                    state.clear()
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .help("Clear all sounds")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}
