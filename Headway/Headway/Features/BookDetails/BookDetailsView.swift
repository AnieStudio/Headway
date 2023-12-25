//
//  BookDetailsView.swift
//  Headway
//
//  Created by Hlib Serediuk-Personal on 23.12.2023.
//

import SwiftUI
import ComposableArchitecture

struct BookDetailsView: View {
    let store: StoreOf<BookDetailsReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            GeometryReader { screen in
                if viewStore.book == .empty {
                    LaunchView()
                } else {
                    ZStack {
                        Color
                            .primaryBackground
                        
                        VStack {
                            VStack {
                                Image(viewStore.book.previewID)
                                    .resizable()
                                    .frame(width: screen.size.width * 0.6, height: screen.size.height * 0.4)
                                    .shadow(radius: 10)
                                    .padding(.top, screen.size.height * 0.03)
                                
                                VStack(spacing: 5) {
                                    Text("KEY POINT \(viewStore.audioInfoState.currentAudioIndex) OF \(viewStore.book.playlist.audio.count - 1)")
                                        .font(.subheadline)
                                        .foregroundStyle(.gray)
                                        .bold()
                                    
                                    Text(viewStore.currentChapterNote)
                                        .foregroundStyle(.black)
                                        .multilineTextAlignment(.center)
                                        .frame(width: screen.size.width * 0.8, height: screen.size.height * 0.1)
                                }
                                .padding(.top, screen.size.height * 0.04)
                            }
                            .padding(.top, screen.size.width * 0.09)
                            
                            HStack {
                                Text(viewStore.audioInfoState.currentTime.toMMSS)
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                                    .frame(width: screen.size.width * 0.1)
                                
                                Slider(
                                    value: viewStore.binding(get: { Float($0.audioInfoState.sliderValue) },
                                                             send: BookDetailsReducer.Action.updateSliderProgress),
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
                                
                                VStack {
                                    Spacer()
                                    
                                    ZStack {
                                        RoundedRectangle(cornerRadius: (screen.size.height * 0.06) / 2)
                                            .stroke(.gray, lineWidth: 1)
                                            .fill(.white)
                                            .frame(width: screen.size.width * 0.275, height: screen.size.height * 0.06)
                                        
                                        HStack(spacing: screen.size.height * 0.01) {
                                            toggleButton(imageName: "headphones", isSelected: true, screenSize: screen.size)
                                            toggleButton(imageName: "text.alignleft", isSelected: false, screenSize: screen.size)
                                        }
                                        
                                    }
                                }
                            }
                            .padding(.top, 20)
                            .frame(height: screen.size.height * 0.2)
                            
                            // Here player controls
                        }
                        .padding(.horizontal, 12)
                    }
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .ignoresSafeArea()
        }
    }
    
    func toggleButton(imageName: String, isSelected: Bool, screenSize: CGSize) -> some View {
        Button {
            
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
    
    func playerViewImage(
        _ store: StoreOf<BookDetailsReducer>,
        _ systemName: String,
        _ screenSize: CGSize,
        _ action: BookDetailsReducer.Action.PlayerAction,
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
    BookDetailsView(store: .init(initialState: BookDetailsReducer.State(bookID: "1"), reducer: {BookDetailsReducer()}))
}
