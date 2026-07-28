import UIKit
import AudioToolbox

enum AppFeedback {
    /// Set to `false` if all `SoundPlayer` usage is removed — Settings will hide the Sound toggle.
    static let hasSoundEffects = true

    static var soundEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: "soundEnabled") == nil { return true }
            return UserDefaults.standard.bool(forKey: "soundEnabled")
        }
        set { UserDefaults.standard.set(newValue, forKey: "soundEnabled") }
    }

    static var hapticEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: "hapticEnabled") == nil { return true }
            return UserDefaults.standard.bool(forKey: "hapticEnabled")
        }
        set { UserDefaults.standard.set(newValue, forKey: "hapticEnabled") }
    }
}

enum HapticFeedback {
    static func light() {
        guard AppFeedback.hapticEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func medium() {
        guard AppFeedback.hapticEnabled else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func success() {
        guard AppFeedback.hapticEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        guard AppFeedback.hapticEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}

enum SoundPlayer {
    static func success() { play(1057) }
    static func tick() { play(1003) }
    static func alertSet() { play(1103) }
    static func syncDone() { play(1104) }

    private static func play(_ soundID: SystemSoundID) {
        guard AppFeedback.hasSoundEffects, AppFeedback.soundEnabled else { return }
        AudioServicesPlaySystemSound(soundID)
    }
}
