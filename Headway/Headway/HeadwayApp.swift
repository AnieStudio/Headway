//
//  HeadwayApp.swift
//  Headway
//
//  Created by Hlib Serediuk-Personal on 23.12.2023.
//

import SwiftUI
import ComposableArchitecture

@main
struct HeadwayApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(
                store: Store(initialState: RootReducer.State()) { RootReducer() }
            )
        }
    }
}
