import Combine
import CoreGraphics
import Foundation

/// Central app controller: owns the layers, presets, playback state and the
/// audio engine, and keeps them in sync.
@MainActor
final class AppState: ObservableObject {
    @Published var layers: [SoundLayer] = []
    @Published var presets: [Preset] = []
    @Published private(set) var isPlaying = false
    @Published var masterVolume: Float = 0.8 {
        didSet { engine.masterVolume = masterVolume; persist() }
    }

    /// Sleep timer: minutes remaining, or nil when off.
    @Published private(set) var timerEndDate: Date?
    private var timerCancellable: AnyCancellable?

    private let engine = AudioEngine()
    private let store = Persistence()
    private let nowPlaying = NowPlayingController()

    init() {
        let session = store.loadSession()
        layers = session.layers
        masterVolume = session.masterVolume
        presets = store.loadPresets()
        if !store.didSeedPresets {
            presets.append(contentsOf: Theme.starters)
            store.savePresets(presets)
            store.didSeedPresets = true
        }
        engine.masterVolume = masterVolume

        nowPlaying.onPlay = { [weak self] in self?.play() }
        nowPlaying.onPause = { [weak self] in self?.pause() }
        nowPlaying.onToggle = { [weak self] in self?.togglePlay() }
    }

    // MARK: - Playback

    func togglePlay() { isPlaying ? pause() : play() }

    func play() {
        engine.sync(layers: layers)
        engine.start()
        isPlaying = true
        nowPlaying.update(isPlaying: true, title: nowPlayingTitle)
    }

    func pause() {
        engine.stop()
        engine.cancelFade()
        isPlaying = false
        cancelTimer()
        nowPlaying.update(isPlaying: false, title: nowPlayingTitle)
    }

    // MARK: - Layers

    func addSound(_ soundID: String, at position: CGPoint = .zero) {
        let layer = SoundLayer(soundID: soundID, position: position)
        layers.append(layer)
        engine.sync(layers: layers)
        if isPlaying { engine.start() } else { play() }
        persist()
    }

    func remove(_ layer: SoundLayer) {
        layers.removeAll { $0.id == layer.id }
        engine.sync(layers: layers)
        persist()
    }

    func move(_ id: UUID, to position: CGPoint) {
        guard let i = layers.firstIndex(where: { $0.id == id }) else { return }
        layers[i].position = position
        engine.apply(layers[i])
    }

    /// Call when a drag ends, to persist the new arrangement.
    func commitMove() { persist() }

    func toggleMute(_ id: UUID) {
        guard let i = layers.firstIndex(where: { $0.id == id }) else { return }
        layers[i].muted.toggle()
        engine.apply(layers[i])
        persist()
    }

    func clear() {
        layers.removeAll()
        engine.sync(layers: layers)
        persist()
    }

    // MARK: - Presets

    func savePreset(named name: String) {
        let preset = Preset(name: name.isEmpty ? "Untitled" : name,
                            layers: layers, masterVolume: masterVolume)
        presets.append(preset)
        store.savePresets(presets)
    }

    func load(_ preset: Preset) {
        layers = preset.layers.map { SoundLayer(soundID: $0.soundID, position: $0.position, muted: $0.muted) }
        masterVolume = preset.masterVolume
        engine.sync(layers: layers)
        play()
        persist()
    }

    func deletePreset(_ preset: Preset) {
        presets.removeAll { $0.id == preset.id }
        store.savePresets(presets)
    }

    // MARK: - Sleep timer

    func startTimer(minutes: Int) {
        cancelTimer()
        let end = Date().addingTimeInterval(TimeInterval(minutes * 60))
        timerEndDate = end
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, let end = self.timerEndDate else { return }
                if Date() >= end { self.fireTimer() }
            }
    }

    func cancelTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
        timerEndDate = nil
        engine.cancelFade()
    }

    private func fireTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
        timerEndDate = nil
        engine.fadeOut(duration: 8) { [weak self] in
            Task { @MainActor in self?.pause() }
        }
    }

    // MARK: - Persistence

    private var nowPlayingTitle: String {
        layers.isEmpty ? "Noice" : "\(layers.count) sound\(layers.count == 1 ? "" : "s")"
    }

    private func persist() {
        store.saveSession(layers: layers, masterVolume: masterVolume)
    }
}
