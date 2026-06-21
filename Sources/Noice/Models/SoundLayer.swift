import CoreGraphics
import Foundation

/// A placed instance of a sound on the spatial canvas.
///
/// `position` is normalized to the unit disc centered on the listener:
/// (0,0) is right on top of the listener (loudest, centered) and the edge of
/// the unit circle is the quietest. x maps to stereo pan, the radial distance
/// maps to volume — "where you place it is the mix".
struct SoundLayer: Identifiable, Codable, Hashable {
    var id: UUID
    var soundID: String
    var position: CGPoint   // normalized, components in roughly [-1, 1]
    var muted: Bool

    init(id: UUID = UUID(), soundID: String, position: CGPoint, muted: Bool = false) {
        self.id = id
        self.soundID = soundID
        self.position = position
        self.muted = muted
    }

    var sound: Sound? { Sound.byID(soundID) }

    /// Distance from the listener at center, clamped to the unit disc.
    var distance: CGFloat {
        min(1, hypot(position.x, position.y))
    }

    /// Spatial volume factor from radial distance: full at center, silent at
    /// the edge. A quarter-cosine keeps sounds clearly present across most of
    /// the canvas (a squared falloff made mid-placed sounds far too quiet).
    /// The per-sound loudness `gain` is applied separately by the audio engine.
    var volume: Float {
        let d = Float(distance)
        return cos(d * .pi / 2)
    }

    /// Stereo pan from horizontal offset.
    var pan: Float {
        Float(max(-1, min(1, position.x)))
    }
}
