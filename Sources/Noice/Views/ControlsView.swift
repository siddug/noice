import SwiftUI

/// Bottom control bar: play/pause, master volume, sleep timer, presets, settings.
struct ControlsView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Button { state.togglePlay() } label: {
                    Image(systemName: state.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 30))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.tint)
                .disabled(state.layers.isEmpty)

                Image(systemName: "speaker.fill").font(.caption).foregroundStyle(.secondary)
                Slider(value: Binding(
                    get: { Double(state.masterVolume) },
                    set: { state.masterVolume = Float($0) }
                ), in: 0...1)
                Image(systemName: "speaker.wave.3.fill").font(.caption).foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                TimerMenu()
                PresetsMenu()
                Spacer()
                SettingsMenu()
            }
            .font(.callout)
        }
        .padding(.horizontal, 14)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}

// MARK: - Sleep timer

private struct TimerMenu: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        Menu {
            ForEach([15, 30, 45, 60, 90, 120], id: \.self) { mins in
                Button("\(mins) minutes") { state.startTimer(minutes: mins) }
            }
            if state.timerEndDate != nil {
                Divider()
                Button("Cancel timer", role: .destructive) { state.cancelTimer() }
            }
        } label: {
            Label(timerLabel, systemImage: "moon.zzz.fill")
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
    }

    private var timerLabel: String {
        guard let end = state.timerEndDate else { return "Timer" }
        let remaining = max(0, Int(end.timeIntervalSinceNow))
        return String(format: "%d:%02d", remaining / 60, remaining % 60)
    }
}

// MARK: - Presets

private struct PresetsMenu: View {
    @EnvironmentObject var state: AppState
    @State private var showingSave = false
    @State private var name = ""

    var body: some View {
        Menu {
            Button("Save current mix…") {
                name = ""
                showingSave = true
            }
            .disabled(state.layers.isEmpty)

            if !state.presets.isEmpty {
                Divider()
                ForEach(state.presets) { preset in
                    Button(preset.name) { state.load(preset) }
                }
                Divider()
                Menu("Delete") {
                    ForEach(state.presets) { preset in
                        Button(preset.name, role: .destructive) { state.deletePreset(preset) }
                    }
                }
            }
        } label: {
            Label("Presets", systemImage: "square.stack.3d.up.fill")
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
        .popover(isPresented: $showingSave, arrowEdge: .bottom) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Name this mix").font(.headline)
                TextField("e.g. Rainy focus", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
                    .onSubmit(save)
                HStack {
                    Spacer()
                    Button("Cancel") { showingSave = false }
                    Button("Save", action: save).keyboardShortcut(.defaultAction)
                }
            }
            .padding(14)
        }
    }

    private func save() {
        state.savePreset(named: name)
        showingSave = false
    }
}

// MARK: - Settings

private struct SettingsMenu: View {
    @State private var launchAtLogin = LaunchAtLogin.isEnabled

    var body: some View {
        Menu {
            Toggle("Launch at login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { _, newValue in
                    LaunchAtLogin.set(newValue)
                }
            Divider()
            Button("Quit Noice") { NSApplication.shared.terminate(nil) }
                .keyboardShortcut("q")
        } label: {
            Image(systemName: "gearshape.fill")
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
    }
}
