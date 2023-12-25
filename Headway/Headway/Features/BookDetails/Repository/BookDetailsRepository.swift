//
//  BookDetailsRepository.swift
//  Headway
//
//  Created by Hlib Serediuk-Personal on 23.12.2023.
//

import Foundation
import Dependencies
import ComposableArchitecture

struct BookDetailsRepository {
    var book: (Book.Identifier) async throws -> Book
}

extension BookDetailsRepository: DependencyKey {
    static var liveValue = BookDetailsRepository { id in
        let previewID = "1.preview"
        let audio: [Audio] = [
            Audio(id: "1.introduction_0", notes: "Good habits produce results that multiply rapidly, just like money that grows whrough compound interest"),
            Audio(id: "1.chapter_1", notes: "Breaking a bad habit is an ardouos task"),
            Audio(id: "1.chapter_2", notes: "Changing who you are is more importent than focusing on your goal because it makes the change sustainable"),
            Audio(id: "1.chapter_3", notes: "Understanding the concept of idenity-based habits and using the habit loop"),
            Audio(id: "1.chapter_4", notes: "The habbit Loop explains that all habits are formed in a four procedure: cue, craving, response, and reward"),
            Audio(id: "1.chapter_5", notes: "You need to become aware of your habits because behavior a change starts with awareness"),
            Audio(id: "1.chapter_6", notes: "Implementation intention and habit stacking are efficient techniques for creating and maintaining wanted habits"),
            Audio(id: "1.chapter_7", notes: "Each living thing understands the world in its way and love undelayed rewards"),
            Audio(id: "1.chapter_8", notes: "The brain's response to enticning opportunities is immediate")
        ]
        let playlist: Playlist = .init(audio: audio)
        
        return Book(id: id, previewID: previewID, playlist: playlist)
    }
}

// MARK: - Dependency

extension DependencyValues {
  var bookDetailsRepository: BookDetailsRepository {
    get { self[BookDetailsRepository.self] }
    set { self[BookDetailsRepository.self] = newValue }
  }
}

