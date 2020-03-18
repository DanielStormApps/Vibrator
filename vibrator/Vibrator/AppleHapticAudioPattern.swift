//
//  AppleHapticAudioPattern.swift
//
//  Created by Daniel Storm on 3/15/20.
//  Copyright © 2020 Daniel Storm (github.com/DanielStormApps).
//

import Foundation
import CoreHaptics

public extension AppleHapticAudioPattern {
    
    static let fileExtension: String = "ahap"
    
    // MARK: - Init
    init?(data: Data) {
        guard let appleHapticAudioPattern: AppleHapticAudioPattern = try? JSONDecoder().decode(AppleHapticAudioPattern.self, from: data) else { return nil }
        self = appleHapticAudioPattern
    }
    
    // MARK: - Dictionary
    func dictionaryRepresentation() -> [CHHapticPattern.Key: Any]? {
        guard let data: Data = try? JSONEncoder().encode(self) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [CHHapticPattern.Key: Any]
    }
    
}

// MARK: - AppleHapticAudioPattern
/// Codable representation of an Apple Haptic and Audio Pattern (AHAP) file.
///
/// # Support
/// - Works with version 1.0 AHAP files generated with [Lofelt Composer](https://composer.lofelt.com).
///   - May work with all version 1.0 AHAP files but this has not been tested.
///
/// - Note: Apple Documentation: [Representing Haptic Patterns in AHAP Files](https://developer.apple.com/documentation/corehaptics/representing_haptic_patterns_in_ahap_files).
public struct AppleHapticAudioPattern: Codable {
    public let version: Double?
    public let pattern: [Pattern]?
    
    enum CodingKeys: CHHapticPattern.Key.RawValue, CodingKey {
        case version = "Version"
        case pattern = "Pattern"
    }
}

// MARK: - Pattern
public struct Pattern: Codable {
    public let event: Event?
    public let parameterCurve: ParameterCurve?
    
    enum CodingKeys: CHHapticPattern.Key.RawValue, CodingKey {
        case event = "Event"
        case parameterCurve = "ParameterCurve"
    }
}

// MARK: - Event
public struct Event: Codable {
    public let time: TimeInterval?
    public let eventType: EventType?
    public let eventDuration: TimeInterval?
    public let eventParameters: [EventParameter]?
    
    enum CodingKeys: CHHapticPattern.Key.RawValue, CodingKey {
        case time = "Time"
        case eventType = "EventType"
        case eventDuration = "EventDuration"
        case eventParameters = "EventParameters"
    }
}

public enum EventType: CHHapticPattern.Key.RawValue, Codable {
    case hapticContinuous = "HapticContinuous"
    case hapticTransient = "HapticTransient"
}

// MARK: - EventParameter
public struct EventParameter: Codable {
    public let parameterID: EventParameterID?
    public let parameterValue: Float?
    
    enum CodingKeys: CHHapticPattern.Key.RawValue, CodingKey {
        case parameterID = "ParameterID"
        case parameterValue = "ParameterValue"
    }
}

public enum EventParameterID: CHHapticPattern.Key.RawValue, Codable {
    case hapticIntensity = "HapticIntensity"
    case hapticSharpness = "HapticSharpness"
}

// MARK: - ParameterCurve
public struct ParameterCurve: Codable {
    public let parameterID: ParameterID?
    public let time: TimeInterval?
    public let parameterCurveControlPoints: [ParameterCurveControlPoint]?
    
    enum CodingKeys: CHHapticPattern.Key.RawValue, CodingKey {
        case parameterID = "ParameterID"
        case time = "Time"
        case parameterCurveControlPoints = "ParameterCurveControlPoints"
    }
}

public enum ParameterID: CHHapticPattern.Key.RawValue, Codable {
    case hapticIntensityControl = "HapticIntensityControl"
    case hapticSharpnessControl = "HapticSharpnessControl"
}

// MARK: - ParameterCurveControlPoint
public struct ParameterCurveControlPoint: Codable {
    public let time: TimeInterval?
    public let parameterValue: Float?
    
    enum CodingKeys: CHHapticPattern.Key.RawValue, CodingKey {
        case time = "Time"
        case parameterValue = "ParameterValue"
    }
}
