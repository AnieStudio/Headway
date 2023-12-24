//
//  Playlist.swift
//  Headway
//
//  Created by Hlib Serediuk-Personal on 24.12.2023.
//

struct Playlist: Equatable {
    let audio: [Audio]
    
    static let empty: Self = .init(audio: [])
}
