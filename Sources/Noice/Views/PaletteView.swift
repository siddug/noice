import SwiftUI

/// Horizontally scrolling palette, grouped by category. Tap a chip to drop the
/// sound near the listener.
struct PaletteView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(Sound.Category.allCases, id: \.self) { category in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(category.rawValue.uppercased())
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .padding(.leading, 2)
                        HStack(spacing: 8) {
                            ForEach(Sound.inCategory(category)) { sound in
                                chip(sound)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
    }

    private func chip(_ sound: Sound) -> some View {
        Button {
            // Drop at a pleasant mid-radius spot, spread by the golden angle so
            // successive sounds don't stack on top of each other.
            let angle = Double(state.layers.count) * 2.39996
            let r = 0.45
            let p = CGPoint(x: r * cos(angle), y: r * sin(angle))
            state.addSound(sound.id, at: p)
        } label: {
            VStack(spacing: 3) {
                Image(systemName: sound.symbol)
                    .font(.system(size: 15))
                    .frame(height: 18)
                Text(sound.name)
                    .font(.system(size: 9))
                    .lineLimit(1)
            }
            .frame(width: 52, height: 44)
            .background(RoundedRectangle(cornerRadius: 8).fill(.secondary.opacity(0.1)))
        }
        .buttonStyle(.plain)
        .help("Add \(sound.name)")
    }
}
