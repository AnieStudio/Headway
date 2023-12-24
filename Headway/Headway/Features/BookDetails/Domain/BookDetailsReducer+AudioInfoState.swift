//
//  AudioInfoState.swift
//  Headway
//
//  Created by Hlib Serediuk-Personal on 25.12.2023.
//

import Foundation

extension BookDetailsReducer.State {
    struct AudioInfoState: Equatable {
        var currentAudioIndex: Int = 0
        var currentTime: TimeInterval = 0
        var totalDuration: TimeInterval = 0
        var currentPlaybackSpeed: AudioPlayerClient.PlaybackSpeed = .normal
        
        static let empty: Self = .init(currentTime: 0, totalDuration: 0)
    }
}
