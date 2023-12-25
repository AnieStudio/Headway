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
    let screen: GeometryProxy
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                VStack(spacing: 5) {
                    Text("KEY POINT \(viewStore.audioInfoState.currentAudioIndex) OF \(viewStore.urlsCount)")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .bold()
                    
                    Text(viewStore.currentChapterNote)
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                        .frame(width: screen.size.width * 0.8, height: screen.size.height * 0.1)
                }
                .padding(.top, screen.size.height * 0.04)
                
                HStack {
                    Text(viewStore.audioInfoState.currentTime.toMMSS)
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .frame(width: screen.size.width * 0.1)
                    
                    Slider(
                        value: viewStore.binding(get: { Float($0.audioInfoState.sliderValue) },
                                                 send: PlayerControlsReducer.Action.updateSliderProgress),
                        in: PlayerAudioInfoState.sliderStep
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
                        playerControlButton(store, "backward.end.fill", screen.size, .back, !viewStore.isFirstAudio)
                            .frame(width: screen.size.width * 0.045, height: screen.size.height * 0.022)
                        playerControlButton(store, "gobackward.5", screen.size, .rewindBack)
                            .frame(width:screen.size.height * 0.028, height: screen.size.height * 0.03)
                        
                        if viewStore.playerState == .pause {
                            playerControlButton(store, "play.fill", screen.size, .play)
                                .frame(width: screen.size.width * 0.06, height: screen.size.height * 0.03)
                        } else {
                            playerControlButton(store, "pause.fill", screen.size, .pause)
                                .frame(width: screen.size.width * 0.055, height: screen.size.height * 0.025)
                        }
                        
                        playerControlButton(store, "goforward.10",screen.size, .rewindForward)
                            .frame(width:screen.size.height * 0.028, height: screen.size.height * 0.03)
                        playerControlButton(store, "forward.end.fill",screen.size, .next, !viewStore.isLastAudio)
                            .frame(width: screen.size.width * 0.045, height: screen.size.height * 0.022)
                        
                    }
                    .frame(maxWidth: screen.size.width * 0.1)
                    
                    VStack {
                        Spacer()
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: (screen.size.height * 0.06) / 2)
                                .stroke(.gray, lineWidth: 1)
                                .fill(.white)
                                .frame(width: screen.size.width * 0.275, height: screen.size.height * 0.06)
                            
                            HStack(spacing: screen.size.height * 0.01) {
                                toggleButton(store, "headphones", !viewStore.shouldPresentText, screen.size, .hideText)
                                toggleButton(store, "text.alignleft", viewStore.shouldPresentText, screen.size, .showText)
                            }
                        }
                    }
                }
                .padding(.top, 20)
                .frame(height: screen.size.height * 0.2)
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}
