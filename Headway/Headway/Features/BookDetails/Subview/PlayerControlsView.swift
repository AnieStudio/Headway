//
//  PlayerControlsView.swift
//  Headway
//
//  Created by Hlib Serediuk-Personal on 25.12.2023.
//

import SwiftUI
import ComposableArchitecture

struct PlayerControlsView: View {
    let store: StoreOf<PlayerControlsReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            GeometryReader { screen in
                VStack {
                    HStack {
                        Text(viewStore.audioInfoState.currentTime.toMMSS)
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .frame(width: screen.size.width * 0.1)
                        
                        Slider(
                            value: viewStore.binding(get: { Float($0.audioInfoState.sliderValue) },
                                                     send: PlayerControlsReducer.Action.updateSliderProgress),
                            in: AudioInfoState.sliderStep
                        )
                        .progressViewStyle(.linear)
                        .tint(.primaryBlue)
                        .onAppear {
                            UISlider.appearance().setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
                        }
                        
                        Text(viewStore.audioInfoState.totalDuration.toMMSS)
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .frame(width: screen.size.width * 0.1)
                    }
                    
                    Button {
                        viewStore.send(.playerAction(.changeSpeed))
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.gray.opacity(0.1))
                                .frame(width: screen.size.width * 0.25, height: screen.size.height * 0.045)
                            
                            Text("Speed x\(viewStore.audioInfoState.currentPlaybackSpeedDescr)")
                                .foregroundStyle(.black)
                                .bold()
                                .font(.callout)
                        }
                    }
                    
                    VStack(spacing: 0) {
                        HStack(spacing: screen.size.width * 0.085) {
                            playerViewImage(store, "backward.end.fill", screen.size, .back, !viewStore.isFirstAudio)
                                .frame(width: screen.size.width * 0.045, height: screen.size.height * 0.022)
                            playerViewImage(store, "gobackward.5", screen.size, .rewindBack)
                                .frame(width:screen.size.height * 0.028, height: screen.size.height * 0.03)
                            if viewStore.playerState == .pause {
                                playerViewImage(store, "play.fill", screen.size, .play)
                                    .frame(width: screen.size.width * 0.06, height: screen.size.height * 0.03)
                            } else {
                                playerViewImage(store, "pause.fill", screen.size, .pause)
                                    .frame(width: screen.size.width * 0.055, height: screen.size.height * 0.025)
                            }
                            playerViewImage(store, "goforward.10",screen.size, .rewindForward)
                                .frame(width:screen.size.height * 0.028, height: screen.size.height * 0.03)
                            playerViewImage(store, "forward.end.fill",screen.size, .next, !viewStore.isLastAudio)
                                .frame(width: screen.size.width * 0.045, height: screen.size.height * 0.022)
                            
                        } // Player
                        .frame(maxWidth: screen.size.width * 0.1)
                    }
                    .padding(.top, 20)
                    .frame(height: screen.size.height * 0.2)
                }
            }
        }
    }
    
    func playerViewImage(
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

#Preview {
    PlayerControlsView(store: .init(initialState: PlayerControlsReducer.State(bookID: "1"), reducer: {PlayerControlsReducer()}))
}
