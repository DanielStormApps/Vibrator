//
//  HomeViewController.swift
//
//  Created by Daniel Storm on 3/17/20.
//  Copyright © 2020 Daniel Storm (github.com/DanielStormApps).
//

import UIKit

final class HomeViewController: UIViewController {
    
    @IBOutlet private weak var deviceHapticSupportLabel: UILabel!
    @IBOutlet private weak var heartHapticButton: UIButton!
    @IBOutlet private weak var heartHapticLoopButton: UIButton!
    @IBOutlet private weak var systemVibrateButton: UIButton!
    @IBOutlet private weak var systemVibrateLoopLowButton: UIButton!
    @IBOutlet private weak var systemVibrateLoopHighButton: UIButton!
    @IBOutlet private weak var stopLoopButton: UIButton!
    
    private static let deviceHapticSupportText_NO: String = "Device Supports Haptics: ❌ No"
    private static let heartbeatHapticFilename: String = "Heartbeat"
    
    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !Vibrator.shared.supportsHaptics {
            deviceHapticSupportLabel.text = HomeViewController.deviceHapticSupportText_NO
            heartHapticButton.isEnabled = false
            heartHapticButton.alpha = 0.4
            heartHapticLoopButton.isEnabled = false
            heartHapticLoopButton.alpha = 0.4
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UIDevice.isSimulator { presentPhysicalDeviceRequiredAlert() }
    }
    
    // MARK: - Alert
    private func presentPhysicalDeviceRequiredAlert() {
        let alert: UIAlertController = UIAlertController(title: "Vibrator Demo",
                                                         message: "A physical device is required to experience haptics and vibrations.",
                                                         preferredStyle: .alert)
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @IBAction private func heartHapticButton(_ button: UIButton) {
        Vibrator.shared.startHaptic(named: HomeViewController.heartbeatHapticFilename, loop: false)
    }
    
    @IBAction private func heartHapticLoopButton(_ button: UIButton) {
        Vibrator.shared.startHaptic(named: HomeViewController.heartbeatHapticFilename, loop: true)
    }
    
    @IBAction private func systemVibrateButton(_ button: UIButton) {
        Vibrator.shared.startVibrate(loop: false)
    }
    
    @IBAction private func systemVibrateLoopLowButton(_ button: UIButton) {
        Vibrator.shared.startVibrate(frequency: .low, loop: true)
    }
    
    @IBAction private func systemVibrateLoopHighButton(_ button: UIButton) {
        Vibrator.shared.startVibrate(frequency: .high, loop: true)
    }
    
    @IBAction private func stopLoopButton(_ button: UIButton) {
        Vibrator.shared.stopHaptic()
        Vibrator.shared.stopVibrate()
    }
    
}
