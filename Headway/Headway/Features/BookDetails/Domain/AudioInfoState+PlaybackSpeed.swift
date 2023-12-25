//
//  AudioInfoState+PlaybackSpeed.swift
//  Headway
//
//  Created by Hlib Serediuk-Personal on 25.12.2023.
//

extension PlayerControlsReducer.State.AudioInfoState {
    var currentPlaybackSpeedDescr: String {
        currentPlaybackSpeed.description
    }
    
    var currentPlaybackSpeedIndex: Int {
        AudioPlayerClient.PlaybackSpeed.allCases.firstIndex(of: currentPlaybackSpeed) ?? 2
    }
}
