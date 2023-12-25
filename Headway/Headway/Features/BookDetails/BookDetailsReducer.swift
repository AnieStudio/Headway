//
//  BookDetailsReducer.swift
//  Headway
//
//  Created by Hlib Serediuk-Personal on 23.12.2023.
//

import SwiftUI
import ComposableArchitecture
import Foundation

struct BookDetailsReducer: Reducer {
    @Dependency(\.bookDetailsRepository) private var bookDetailsRepository
    
    struct State: Equatable {
        var bookID: Book.Identifier
        var book: Book = .empty
    }
    
    enum Action: Equatable {
        case onAppear
        case bookFetched(Book)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let id = state.bookID
                
                return .run { send in
                    let book = try await bookDetailsRepository.book(id)
                    await send(.bookFetched(book))
                }
            case let .bookFetched(book):
                state.book = book
                return .none
            }
        }
    }
}
