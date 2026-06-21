import Foundation
import MediaPlayer

/// Wires up media keys / Control Center via MPRemoteCommandCenter so play/pause
/// works from the keyboard, and publishes Now Playing info.
final class NowPlayingController {
    var onPlay: (() -> Void)?
    var onPause: (() -> Void)?
    var onToggle: (() -> Void)?

    init() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget { [weak self] _ in self?.onPlay?(); return .success }
        center.pauseCommand.addTarget { [weak self] _ in self?.onPause?(); return .success }
        center.togglePlayPauseCommand.addTarget { [weak self] _ in self?.onToggle?(); return .success }
        // We don't support seeking/skip; leave those disabled.
        center.nextTrackCommand.isEnabled = false
        center.previousTrackCommand.isEnabled = false
    }

    func update(isPlaying: Bool, title: String) {
        let info = MPNowPlayingInfoCenter.default()
        info.nowPlayingInfo = [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyArtist: "Noice",
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0,
        ]
        info.playbackState = isPlaying ? .playing : .paused
    }
}
