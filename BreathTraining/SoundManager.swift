import AVFoundation
import UIKit

final class SoundManager {
    static let shared = SoundManager()

    private var player: AVAudioPlayer?
    private var stopWorkItem: DispatchWorkItem?

    private init() {}

    func startPhaseSound(profile: BreathSoundProfile, phase: BreathPhase, durationSeconds: Int) {
        stop()

        let resourceName = phase == .inhale ? profile.inhaleResourceName : profile.exhaleResourceName
        let url = Bundle.main.url(forResource: resourceName, withExtension: "mp3")
            ?? Bundle.main.url(forResource: resourceName, withExtension: nil)
        guard let url else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.numberOfLoops = 0
            audioPlayer.volume = 1.0
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            player = audioPlayer

            let workItem = DispatchWorkItem { [weak self] in
                self?.stop()
            }
            stopWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(max(1, durationSeconds)), execute: workItem)
        } catch {
            return
        }
    }

    func stop() {
        stopWorkItem?.cancel()
        stopWorkItem = nil
        player?.stop()
        player = nil
    }

    func haptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}
