//
//  AudioPlayerClient+Extensions.swift
//  Headway
//
//  Created by Hlib Serediuk-Personal on 25.12.2023.
//

import Foundation

extension AudioPlayerClient {
    enum Action: Equatable {
        case play(TimeInterval, PlaybackSpeed)
    }
    
    enum PlaybackSpeed: Float, CaseIterable {
        case half = 0.5
        case threeQuarters = 0.75
        case normal = 1.0
        case oneAndAQuarter = 1.25
        case oneAndAHalf = 1.5
        case oneAndThreeQuarters = 1.75
        case double = 2.0
        
        var description: String {
            switch self {
            case .half:
                return "0.5"
            case .threeQuarters:
                return "0.75"
            case .normal:
                return "1"
            case .oneAndAQuarter:
                return "1.25"
            case .oneAndAHalf:
                return "1.5"
            case .oneAndThreeQuarters:
                return "1.75"
            case .double:
                return "2"
            }
        }
    }
}
