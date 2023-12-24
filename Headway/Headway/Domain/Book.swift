//
//  Book.swift
//  Headway
//
//  Created by Hlib Serediuk-Personal on 23.12.2023.
//

import Foundation

typealias Books = [Book]

struct Book: Identifiable, Equatable {
    typealias Identifier = String
    
    let id: Identifier
    let previewID: Identifier
    let playlist: Playlist
    
    var urls: [URL] {
        playlist
            .audio
            .compactMap { Bundle.main.path(forResource: $0.id, ofType: FileType.mp3.description) }
            .compactMap { URL(filePath: $0) }
    }
    
    static let empty: Self = .init(id: "", previewID: "", playlist: .empty)
}
