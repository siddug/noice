import SwiftUI

/// A draggable sound token on the canvas. Brightness/scale hint at how loud it
/// is (closer to the listener = louder). Hovering reveals a × to remove it.
struct SoundPuckView: View {
    let layer: SoundLayer
    var onRemove: () -> Void

    @State private var hovering = false

    private var intensity: Double { Double(layer.volume) }

    var body: some View {
        puck
            .overlay(alignment: .topTrailing) { removeButton }
            .padding(8)                      // room for the × to sit in the corner
            .contentShape(Rectangle())       // keep hover steady over the whole area
            .onHover { hovering = $0 }
            .animation(.easeInOut(duration: 0.12), value: hovering)
            .help(layer.sound?.name ?? "")
    }

    private var puck: some View {
        Image(systemName: layer.sound?.symbol ?? "questionmark")
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(layer.muted ? AnyShapeStyle(.secondary) : AnyShapeStyle(.tint))
            .frame(width: 44, height: 44)
            .background(
                Circle().fill(.tint.opacity(layer.muted ? 0.06 : 0.12 + 0.25 * intensity))
            )
            .overlay(Circle().stroke(.tint.opacity(layer.muted ? 0.2 : 0.4), lineWidth: 1))
            .overlay(alignment: .bottomTrailing) {
                if layer.muted {
                    Image(systemName: "speaker.slash.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                        .padding(2)
                        .background(Circle().fill(.background))
                }
            }
            .scaleEffect(0.9 + 0.2 * intensity)
            .shadow(color: Color.accentColor.opacity(layer.muted ? 0 : 0.3 * intensity), radius: 6)
    }

    @ViewBuilder
    private var removeButton: some View {
        if hovering {
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 16, height: 16)
                    .background(Circle().fill(Color.red))
                    .overlay(Circle().stroke(.white.opacity(0.6), lineWidth: 0.5))
            }
            .buttonStyle(.plain)
            .offset(x: 8, y: -8)
            .transition(.scale.combined(with: .opacity))
            .help("Remove")
        }
    }
}
