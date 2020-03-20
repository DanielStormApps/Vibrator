//
//  Vibrator.swift
//
//  Created by Daniel Storm on 3/4/20.
//  Copyright © 2020 Daniel Storm (github.com/DanielStormApps).
//

import Foundation
import AudioToolbox
import CoreHaptics

/// A class that allows your app to play system vibrations and Apple Haptic and Audio Pattern (AHAP) files generated with [Lofelt Composer](https://composer.lofelt.com).
public class Vibrator {
    
    /// Options for device vibration rates when looping.
    public enum Frequency {
        case high
        case low
        
        fileprivate var timeInterval: TimeInterval {
            switch self {
            case .high: return 0.01
            case .low: return 1.0
            }
        }
    }
    
    /// Indicates if the device supports haptic event playback.
    public let supportsHaptics: Bool = {
        return CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }()
    
    private var hapticEngine: CHHapticEngine? {
        didSet {
            guard let hapticEngine: CHHapticEngine = hapticEngine else { return }
            hapticEngine.playsHapticsOnly = true
            hapticEngine.isAutoShutdownEnabled = false
            hapticEngine.notifyWhenPlayersFinished { (_) -> CHHapticEngine.FinishedAction in return .leaveEngineRunning }
            hapticEngine.stoppedHandler = { reason in self.hapticEngineDidStop(reason: reason) }
            hapticEngine.resetHandler = { self.hapticEngineDidRecoverFromServerError() }
        }
    }
    
    private var hapticPlayer: CHHapticPatternPlayer?
    
    private var vibrateLoopTimer: Timer?
    private var hapticLoopTimer: Timer?
    
    // MARK: - Init
    /// The shared singleton instance.
    public static let shared: Vibrator = Vibrator()
    private init() {
        guard supportsHaptics else { return }
        hapticEngine = try? CHHapticEngine()
    }
    
    /// Prepares the vibrator by acquiring hardware needed for vibrations.
    public func prepare() {
        guard let hapticEngine: CHHapticEngine = hapticEngine else { return }
        try? hapticEngine.start()
    }
    
    // MARK: - Vibrate
    /// Vibrates the device.
    /// - Parameters:
    ///   - frequency: Rate at which device vibrates when looping. Has no effect if `loop` is `false`.
    ///   - loop: Determines whether the vibration repeats itself based on the `frequency`.
    public func startVibrate(frequency: Vibrator.Frequency = Vibrator.Frequency.low, loop: Bool) {
        stopVibrate()
        
        loop
            ? playVibrateSystemSoundLoop(frequency: frequency)
            : playVibrateSystemSound()
    }
    
    /// Stops vibrating the device.
    ///
    /// Has no effect if `loop` is `false` when starting the vibration.
    public func stopVibrate() {
        stopVibrateLoopTimer()
    }
    
    @objc private func playVibrateSystemSound() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    private func playVibrateSystemSoundLoop(frequency: Vibrator.Frequency) {
        playVibrateSystemSound()
        startVibrateLoopTimer(frequency: frequency)
    }
    
    private func startVibrateLoopTimer(frequency: Vibrator.Frequency) {
        guard vibrateLoopTimer == nil else { return }
        vibrateLoopTimer = Timer.scheduledTimer(timeInterval: frequency.timeInterval,
                                                target: self,
                                                selector: #selector(playVibrateSystemSound),
                                                userInfo: nil,
                                                repeats: true)
    }
    
    private func stopVibrateLoopTimer() {
        guard
            let timer: Timer = vibrateLoopTimer,
            timer.isValid
            else { return }
        
        timer.invalidate()
        vibrateLoopTimer = nil
    }
    
    // MARK: - Haptics
    /// Plays an Apple Haptic and Audio Pattern (AHAP) file.
    /// - Parameters:
    ///   - filename: The filename of the AHAP file containing the haptic pattern.
    ///   - loop: Determines whether the haptic repeats itself on completion.
    public func startHaptic(named filename: String, loop: Bool) {
        stopHaptic()
        
        loop
            ? playHapticLoop(named: filename)
            : playHaptic(named: filename)
    }
    
    /// Stops the current playing haptic pattern.
    ///
    /// Has no effect if `loop` is `false` when starting the haptic.
    public func stopHaptic() {
        stopHapticLoopTimer()
        try? hapticPlayer?.stop(atTime: CHHapticTimeImmediate)
        hapticPlayer = nil
    }
    
    private func playHaptic(named filename: String) {
        guard
            let hapticEngine: CHHapticEngine = hapticEngine,
            let hapticPath: String = Bundle.main.path(forResource: filename, ofType: AppleHapticAudioPattern.fileExtension)
            else { return }
        
        try? hapticEngine.start()
        try? hapticEngine.playPattern(from: URL(fileURLWithPath: hapticPath))
    }
    
    private func playHapticLoop(named filename: String) {
        guard
            let hapticEngine: CHHapticEngine = hapticEngine,
            let hapticPath: String = Bundle.main.path(forResource: filename, ofType: AppleHapticAudioPattern.fileExtension),
            let hapticData: Data = try? Data(contentsOf: URL(fileURLWithPath: hapticPath)),
            let appleHapticAudioPattern: AppleHapticAudioPattern = AppleHapticAudioPattern(data: hapticData),
            let appleHapticAudioPatternDictionary: [CHHapticPattern.Key: Any] = appleHapticAudioPattern.dictionaryRepresentation(),
            let hapticDuration: TimeInterval = appleHapticAudioPattern.pattern?.first(where: { $0.event?.eventDuration != nil })?.event?.eventDuration,
            let hapticPattern: CHHapticPattern = try? CHHapticPattern(dictionary: appleHapticAudioPatternDictionary),
            let hapticPlayer: CHHapticPatternPlayer = try? hapticEngine.makePlayer(with: hapticPattern)
            else { return }
        
        try? hapticEngine.start()
        self.hapticPlayer = hapticPlayer
        try? self.hapticPlayer?.start(atTime: CHHapticTimeImmediate)
        startHapticLoopTimer(timeInterval: hapticDuration)
    }
    
    @objc private func restartHapticPlayer() {
        try? hapticPlayer?.start(atTime: 0.0)
    }
    
    private func startHapticLoopTimer(timeInterval: TimeInterval) {
        guard hapticLoopTimer == nil else { return }
        hapticLoopTimer = Timer.scheduledTimer(timeInterval: timeInterval,
                                               target: self,
                                               selector: #selector(restartHapticPlayer),
                                               userInfo: nil,
                                               repeats: true)
    }
    
    private func stopHapticLoopTimer() {
        guard
            let timer: Timer = hapticLoopTimer,
            timer.isValid
            else { return }
        
        timer.invalidate()
        hapticLoopTimer = nil
    }
    
    /// Called when the haptic engine stops due to an external reason.
    private func hapticEngineDidStop(reason: CHHapticEngine.StoppedReason) {
        log("\(#function) -> reason: \(reason)")
    }
    
    /// Called when the haptic engine fails. Will attempt to restart the haptic engine.
    private func hapticEngineDidRecoverFromServerError() {
        log("\(#function)")
        try? hapticEngine?.start()
    }
    
}

private extension Vibrator {
    
    // MARK: - Logging
    func log(_ message: String) {
        #if DEBUG
            print("\n📳 \(String(describing: Vibrator.self)): \(#function) -> message: \(message)\n")
        #endif
    }
    
}
