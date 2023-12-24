//
//  RootReducer.swift
//  Headway
//
//  Created by Hlib Serediuk-Personal on 23.12.2023.
//

import ComposableArchitecture
import SwiftUI

struct RootReducer: Reducer {
    struct State: Equatable {
        var launchState = LaunchViewReducer.State()
        var detailsState = BookDetailsReducer.State(bookID: "1")
    }
    
    enum Action: Equatable {
        case launchAction(LaunchViewReducer.Action)
        case bookDetailsAction(BookDetailsReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(
            state: \.launchState,
            action: /Action.launchAction
        ) {
            LaunchViewReducer()
        }
        
        Scope(state: \.detailsState, action: /Action.bookDetailsAction) {
            BookDetailsReducer()
        }
    }
}
