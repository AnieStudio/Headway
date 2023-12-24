//
//  RootView.swift
//  Headway
//
//  Created by Hlib Serediuk-Personal on 23.12.2023.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    let store: StoreOf<RootReducer>
    
    var body: some View {
        BookDetailsView(store: store.scope(state: \.detailsState, action: RootReducer.Action.bookDetailsAction))
//        LaunchView(
//            store: store.scope(state: \.launchState, action: RootReducer.Action.launchAction)
//        )
    }
}
