import Foundation

/// A catalog sound. Audio is a looping `.m4a` bundled under `Resources/Sounds`.
///
/// `gain` is a per-sound loudness-normalization multiplier: the bundled files
/// come from different sources at wildly different levels (forest was ~14 dB
/// quieter than wind), so each gain brings the sound toward a common perceived
/// loudness (~-20 LUFS), capped so peaks stay below clipping.
struct Sound: Identifiable, Hashable {
    let id: String
    let name: String
    let symbol: String     // SF Symbol name
    let file: String       // resource filename (without extension), in Sounds/
    let category: Category
    let gain: Float

    enum Category: String, CaseIterable {
        case weather = "Weather"
        case water   = "Water"
        case nature  = "Nature"
        case places  = "Places"
        case ambient = "Ambient"
        case noise   = "Noise"
    }

    static let catalog: [Sound] = [
        // Weather
        Sound(id: "rain",     name: "Rain",     symbol: "cloud.rain.fill",      file: "rain",        category: .weather, gain: 1.00),
        Sound(id: "thunder",  name: "Thunder",  symbol: "cloud.bolt.rain.fill", file: "thunder",     category: .weather, gain: 1.00),
        Sound(id: "wind",     name: "Wind",     symbol: "wind",                 file: "wind",        category: .weather, gain: 1.00),
        // Water
        Sound(id: "ocean",    name: "Ocean",    symbol: "water.waves",          file: "waves",       category: .water,   gain: 1.00),
        Sound(id: "stream",   name: "Stream",   symbol: "drop.fill",            file: "stream",      category: .water,   gain: 1.00),
        // Nature
        Sound(id: "forest",   name: "Forest",   symbol: "tree.fill",            file: "forest",      category: .nature,  gain: 1.00),
        Sound(id: "fire",     name: "Fire",     symbol: "flame.fill",           file: "fire",        category: .nature,  gain: 1.00),
        Sound(id: "birds",    name: "Birds",    symbol: "bird.fill",            file: "birds",       category: .nature,  gain: 1.00),
        Sound(id: "crickets", name: "Crickets", symbol: "moon.stars.fill",      file: "crickets",    category: .nature,  gain: 1.00),
        // Places
        Sound(id: "city",     name: "City",     symbol: "building.2.fill",      file: "city",        category: .places,  gain: 1.00),
        Sound(id: "cafe",     name: "Café",     symbol: "cup.and.saucer.fill",  file: "coffee-shop", category: .places,  gain: 1.00),
        // Ambient
        Sound(id: "chimes",   name: "Chimes",   symbol: "bell.fill",            file: "chimes",      category: .ambient, gain: 1.00),
        Sound(id: "fan",      name: "Fan",      symbol: "fanblades.fill",       file: "fan",         category: .ambient, gain: 1.00),
        Sound(id: "train",    name: "Train",    symbol: "tram.fill",            file: "train",       category: .ambient, gain: 1.00),
        // Noise
        Sound(id: "white",    name: "White",    symbol: "waveform",             file: "white-noise", category: .noise,   gain: 1.00),
        Sound(id: "pink",     name: "Pink",     symbol: "waveform.path",        file: "pink-noise",  category: .noise,   gain: 1.00),
        Sound(id: "brown",    name: "Brown",    symbol: "waveform.path.ecg",    file: "brown-noise", category: .noise,   gain: 1.00),
    ]

    static func byID(_ id: String) -> Sound? {
        catalog.first { $0.id == id }
    }

    static func inCategory(_ category: Category) -> [Sound] {
        catalog.filter { $0.category == category }
    }
}
