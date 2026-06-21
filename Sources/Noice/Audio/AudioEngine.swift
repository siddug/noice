import AVFoundation
import Foundation

/// Owns the AVAudioEngine and one looping player node per placed layer.
/// Per-layer volume/pan come from the layer's canvas position; the engine just
/// reflects whatever the app state tells it.
final class AudioEngine {
    private let engine = AVAudioEngine()
    private var players: [UUID: AVAudioPlayerNode] = [:]
    private var bufferCache: [String: AVAudioPCMBuffer] = [:]   // keyed by sound id

    private var sampleRate: Double { engine.mainMixerNode.outputFormat(forBus: 0).sampleRate }
    private(set) var isRunning = false

    /// Master volume in [0, 1]; applied even while fading.
    var masterVolume: Float = 0.8 {
        didSet { engine.mainMixerNode.outputVolume = masterVolume * fadeMultiplier }
    }
    private var fadeMultiplier: Float = 1 {
        didSet { engine.mainMixerNode.outputVolume = masterVolume * fadeMultiplier }
    }

    func start() {
        guard !isRunning else { return }
        engine.mainMixerNode.outputVolume = masterVolume * fadeMultiplier
        do {
            try engine.start()
            isRunning = true
            for player in players.values where !player.isPlaying {
                player.play()
            }
        } catch {
            NSLog("Noice: failed to start engine: \(error)")
        }
    }

    func stop() {
        guard isRunning else { return }
        for player in players.values { player.pause() }
        engine.pause()
        isRunning = false
    }

    /// Reconcile live player nodes with the desired set of layers.
    func sync(layers: [SoundLayer]) {
        let desired = Set(layers.map(\.id))

        // Remove players for layers that no longer exist.
        for (id, player) in players where !desired.contains(id) {
            player.stop()
            engine.detach(player)
            players[id] = nil
        }

        // Add players for new layers; update all.
        for layer in layers {
            if players[layer.id] == nil {
                guard let sound = layer.sound,
                      let buffer = buffer(for: sound) else { continue }
                let player = AVAudioPlayerNode()
                engine.attach(player)
                engine.connect(player, to: engine.mainMixerNode,
                               format: buffer.format)
                player.scheduleBuffer(buffer, at: nil, options: [.loops])
                players[layer.id] = player
                if isRunning { player.play() }
            }
            apply(layer)
        }
    }

    /// Push a single layer's volume/pan/mute to its player node, scaling by the
    /// sound's loudness-normalization gain.
    func apply(_ layer: SoundLayer) {
        guard let player = players[layer.id] else { return }
        let gain = layer.sound?.gain ?? 1
        player.volume = layer.muted ? 0 : layer.volume * gain
        player.pan = layer.pan
    }

    /// Smoothly fade the master out (for the sleep timer), then run completion.
    func fadeOut(duration: TimeInterval, completion: @escaping () -> Void) {
        let steps = 60
        let interval = duration / Double(steps)
        var step = 0
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            step += 1
            self.fadeMultiplier = max(0, 1 - Float(step) / Float(steps))
            if step >= steps {
                timer.invalidate()
                self.fadeMultiplier = 1   // reset for next play
                completion()
            }
        }
    }

    func cancelFade() { fadeMultiplier = 1 }

    /// Load (and cache) a sound's looping buffer from its bundled .m4a file.
    private func buffer(for sound: Sound) -> AVAudioPCMBuffer? {
        if let cached = bufferCache[sound.id] { return cached }
        guard let url = Bundle.module.url(forResource: sound.file,
                                          withExtension: "m4a",
                                          subdirectory: "Sounds") else {
            NSLog("Noice: missing audio file for \(sound.id)")
            return nil
        }
        do {
            let file = try AVAudioFile(forReading: url)
            let format = file.processingFormat
            let frames = AVAudioFrameCount(file.length)
            guard frames > 0,
                  let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames) else {
                return nil
            }
            try file.read(into: buffer)
            bufferCache[sound.id] = buffer
            return buffer
        } catch {
            NSLog("Noice: failed to read \(sound.id): \(error)")
            return nil
        }
    }
}
