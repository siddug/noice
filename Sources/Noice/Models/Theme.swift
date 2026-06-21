import CoreGraphics
import Foundation

/// Curated starter mixes ("themes") seeded as presets on first launch.
/// Positions are normalized canvas coordinates: nearer the center (0,0) = louder.
enum Theme {
    private static func layer(_ soundID: String, _ x: CGFloat, _ y: CGFloat) -> SoundLayer {
        SoundLayer(soundID: soundID, position: CGPoint(x: x, y: y))
    }

    static let starters: [Preset] = [
        Preset(name: "Rainy Café", layers: [
            layer("rain", 0.0, 0.2),
            layer("cafe", -0.5, 0.35),
            layer("chimes", 0.7, -0.45),
        ], masterVolume: 0.8),

        Preset(name: "Cozy Fire", layers: [
            layer("fire", 0.0, 0.15),
            layer("wind", 0.55, -0.5),
            layer("crickets", -0.6, 0.4),
        ], masterVolume: 0.8),

        Preset(name: "Ocean Sleep", layers: [
            layer("ocean", 0.0, 0.25),
            layer("wind", -0.45, -0.4),
        ], masterVolume: 0.75),

        Preset(name: "Forest Morning", layers: [
            layer("forest", 0.0, 0.3),
            layer("birds", 0.5, -0.35),
            layer("stream", -0.5, 0.25),
        ], masterVolume: 0.8),

        Preset(name: "Deep Focus", layers: [
            layer("brown", 0.0, 0.45),
            layer("rain", 0.45, 0.3),
        ], masterVolume: 0.7),
    ]
}
