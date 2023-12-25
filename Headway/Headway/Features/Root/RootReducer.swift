//
//  RootReducer.swift
//  Headway
//
//  Created by Hlib Serediuk-Personal on 23.12.2023.
//

import ComposableArchitecture
import SwiftUI

struct RootReducer: Reducer {
    private enum Constant {
        static let stubBookID = "1"
    }
    
    struct State: Equatable {
        var detailsState = BookDetailsReducer.State(bookID: Constant.stubBookID)
    }
    
    enum Action: Equatable {
        case bookDetailsAction(BookDetailsReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.detailsState, action: /Action.bookDetailsAction) {
            BookDetailsReducer()
        }
    }
}
