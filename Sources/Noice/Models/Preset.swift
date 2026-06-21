import Foundation

/// A saved arrangement of sound layers and master volume.
struct Preset: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var layers: [SoundLayer]
    var masterVolume: Float

    init(id: UUID = UUID(), name: String, layers: [SoundLayer], masterVolume: Float) {
        self.id = id
        self.name = name
        self.layers = layers
        self.masterVolume = masterVolume
    }
}
