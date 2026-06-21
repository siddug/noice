import Foundation

/// Lightweight JSON persistence in UserDefaults for the last session and presets.
struct Persistence {
    private let defaults = UserDefaults.standard
    private let sessionLayersKey = "session.layers"
    private let sessionVolumeKey = "session.masterVolume"
    private let presetsKey = "presets.v1"
    private let didSeedKey = "presets.didSeed.v1"

    var didSeedPresets: Bool {
        get { defaults.bool(forKey: didSeedKey) }
        nonmutating set { defaults.set(newValue, forKey: didSeedKey) }
    }

    func saveSession(layers: [SoundLayer], masterVolume: Float) {
        if let data = try? JSONEncoder().encode(layers) {
            defaults.set(data, forKey: sessionLayersKey)
        }
        defaults.set(masterVolume, forKey: sessionVolumeKey)
    }

    func loadSession() -> (layers: [SoundLayer], masterVolume: Float) {
        var layers: [SoundLayer] = []
        if let data = defaults.data(forKey: sessionLayersKey),
           let decoded = try? JSONDecoder().decode([SoundLayer].self, from: data) {
            layers = decoded
        }
        let volume = defaults.object(forKey: sessionVolumeKey) as? Float ?? 0.8
        return (layers, volume)
    }

    func savePresets(_ presets: [Preset]) {
        if let data = try? JSONEncoder().encode(presets) {
            defaults.set(data, forKey: presetsKey)
        }
    }

    func loadPresets() -> [Preset] {
        guard let data = defaults.data(forKey: presetsKey),
              let presets = try? JSONDecoder().decode([Preset].self, from: data) else {
            return []
        }
        return presets
    }
}
