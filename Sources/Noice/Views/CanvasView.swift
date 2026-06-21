import SwiftUI

/// The spatial canvas. The listener sits at the center; each sound is a puck
/// you drag around. Radial distance sets volume, horizontal offset sets pan.
struct CanvasView: View {
    @EnvironmentObject var state: AppState
    private let space = "canvas"

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = side / 2 - 26

            ZStack {
                guides(center: center, radius: radius)
                listener(at: center)

                if state.layers.isEmpty {
                    Text("Add a sound below")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .position(x: center.x, y: center.y + radius * 0.55)
                }

                ForEach(state.layers) { layer in
                    SoundPuckView(layer: layer, onRemove: { state.remove(layer) })
                        .position(screenPoint(layer.position, center: center, radius: radius))
                        .gesture(
                            DragGesture(coordinateSpace: .named(space))
                                .onChanged { value in
                                    let p = normalize(value.location, center: center, radius: radius)
                                    state.move(layer.id, to: p)
                                }
                                .onEnded { _ in state.commitMove() }
                        )
                        .onTapGesture { state.toggleMute(layer.id) }
                        .contextMenu {
                            Button(layer.muted ? "Unmute" : "Mute") { state.toggleMute(layer.id) }
                            Button("Remove", role: .destructive) { state.remove(layer) }
                        }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .coordinateSpace(name: space)
        }
        .padding(.horizontal, 14)
    }

    private func guides(center: CGPoint, radius: CGFloat) -> some View {
        ZStack {
            ForEach([1.0, 0.66, 0.33], id: \.self) { scale in
                Circle()
                    .stroke(.secondary.opacity(0.18), lineWidth: 1)
                    .frame(width: radius * 2 * scale, height: radius * 2 * scale)
                    .position(center)
            }
        }
    }

    private func listener(at center: CGPoint) -> some View {
        Image(systemName: "person.fill")
            .font(.system(size: 13))
            .foregroundStyle(.secondary)
            .padding(7)
            .background(Circle().fill(.secondary.opacity(0.12)))
            .position(center)
    }

    // MARK: - Coordinate mapping

    private func screenPoint(_ p: CGPoint, center: CGPoint, radius: CGFloat) -> CGPoint {
        CGPoint(x: center.x + p.x * radius, y: center.y + p.y * radius)
    }

    private func normalize(_ loc: CGPoint, center: CGPoint, radius: CGFloat) -> CGPoint {
        var p = CGPoint(x: (loc.x - center.x) / radius, y: (loc.y - center.y) / radius)
        let len = hypot(p.x, p.y)
        if len > 1 {                     // clamp to the unit disc
            p.x /= len
            p.y /= len
        }
        return p
    }
}
