//
//  PlayerControlsView+Extensions.swift
//  Headway
//
//  Created by Hlib Serediuk-Personal on 25.12.2023.
//

import SwiftUI
import ComposableArchitecture

extension PlayerControlsView {
    func toggleButton(
        _ store: StoreOf<PlayerControlsReducer>,
        _ imageName: String,
        _ isSelected: Bool,
        _ screenSize: CGSize,
        _ action: PlayerControlsReducer.Action
    ) -> some View {
        Button {
            store.send(action)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: (screenSize.height * 0.055) / 2)
                    .fill(isSelected ? .primaryBlue : .clear)
                    .frame(width: screenSize.height * 0.055, height: screenSize.height * 0.055)
                
                Image(systemName: imageName)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: screenSize.width * 0.065, height: screenSize.height * 0.03)
                    .foregroundStyle(isSelected ? .white : .black)
            }
        }
    }
    
    func playerControlButton(
        _ store: StoreOf<PlayerControlsReducer>,
        _ systemName: String,
        _ screenSize: CGSize,
        _ action: PlayerControlsReducer.Action.PlayerAction,
        _ isEnabled: Bool = true
    ) -> some View {
        Button {
            store.send(.playerAction(action))
        } label: {
            Image(systemName: systemName)
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(isEnabled ? .black : .gray)
        }
        .disabled(!isEnabled)
    }
}
