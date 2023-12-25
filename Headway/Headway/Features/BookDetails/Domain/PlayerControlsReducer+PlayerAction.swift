//
//  BookDetailsReducer+PlayerAction.swift
//  Headway
//
//  Created by Hlib Serediuk-Personal on 25.12.2023.
//

extension PlayerControlsReducer.Action {
    enum PlayerAction: Equatable {
        case play
        case pause
        case back
        case next
        case rewindBack
        case rewindForward
        case changeSpeed
        case didFinishPlaying
    }
}
