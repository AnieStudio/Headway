//
//  BookDetailsReducer+PlayerAction.swift
//  Headway
//
//  Created by Hlib Serediuk-Personal on 25.12.2023.
//

extension BookDetailsReducer.Action {
    enum PlayerAction: Equatable {
        case play
        case pause
        case back
        case next
        case goBack5
        case goForward10
        case changeSpeed
        case didFinishPlaying
    }
}
