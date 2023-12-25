//
//  PlayerControlsReducer.swift
//  Headway
//
//  Created by Hlib Serediuk-Personal on 25.12.2023.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct PlayerControlsReducer: Reducer {
    @Dependency(\.continuousClock) private var clock
    @Dependency(\.audioPlayer) private var audioPlayer
    
    private enum Constant {
        static let rewindBackTime: Double = 5
        static let rewindForwardTime: Double = 10
    }
    
    private enum CancelID {
        case play
        case timer
    }
    
    struct State: Equatable {
        var book: Book
        var playerState: PlayerState = .pause
        var audioInfoState: AudioInfoState = .empty
        var shouldPresentText: Bool = false
        var urlsCount: Int {
            book.playlist.audio.count - 1
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case startTimer
        case updateCurrentAudioTime
        case updateSliderProgress(Float)
        case getTotalDuration(TimeInterval)
        case showText
        case hideText
        case playerAction(PlayerAction)
    }
    
    var body: some Reducer<State, Action> {
        let defaultCalncelEffects: [Effect<PlayerControlsReducer.Action>] = [
            .cancel(id: CancelID.play),
            .cancel(id: CancelID.timer)
        ]
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                
                return .run { [url = state.book.urls[state.audioInfoState.currentAudioIndex]] send in
                    let duration = try await audioPlayer.totalDuration(url)
                    await send(.getTotalDuration(duration))
                }
            case let .playerAction(action):
                switch action {
                case .play:
                    state.playerState = .playing
                    let time = state.audioInfoState.currentTime
                    let speed = state.audioInfoState.currentPlaybackSpeed
                    
                    return .run(priority: .high) { [url = state.book.urls[state.audioInfoState.currentAudioIndex]] send in
                        await send(.startTimer)
                        
                        // TODO: recheck and handle error 
                        _ = try await audioPlayer.control(url, .play(time, speed))
                    }
                    .cancellable(id: CancelID.play, cancelInFlight: true)
                case .pause:
                    state.playerState = .pause
                    
                    return .merge(.cancel(id: CancelID.play), .cancel(id: CancelID.timer))
                case .back:
                    guard !state.isFirstAudio else { return .none }
                    
                    var effects = defaultCalncelEffects
                    
                    effects.append(
                        .run { [url = state.book.urls[state.audioInfoState.currentAudioIndex]] send in
                            let duration = try await audioPlayer.totalDuration(url)
                            await send(.getTotalDuration(duration))
                        }
                    )
                    
                    state.audioInfoState.currentAudioIndex -= 1
                    state.audioInfoState.currentTime = 0
                    state.audioInfoState.totalDuration = 0
                    
                    playIfNeeded(state, &effects)
                    
                    return .merge(effects)
                case .next:
                    guard !state.isLastAudio else { return .none }
                    var effects = defaultCalncelEffects
                    
                    effects.append(
                        .run { [url = state.book.urls[state.audioInfoState.currentAudioIndex]] send in
                            let duration = try await audioPlayer.totalDuration(url)
                            await send(.getTotalDuration(duration))
                        }
                    )
                    state.audioInfoState.currentAudioIndex += 1
                    state.audioInfoState.currentTime = 0
                    state.audioInfoState.totalDuration = 0
                    
                    playIfNeeded(state, &effects)
                    return .merge(effects)
                    
                case .rewindBack:
                    guard state.audioInfoState.currentTime != 0 else { return .none }
                    if state.audioInfoState.currentTime <= Constant.rewindBackTime {
                        state.audioInfoState.currentTime = 0
                        
                    } else {
                        state.audioInfoState.currentTime -= Constant.rewindBackTime
                    }
                    
                    var effects = defaultCalncelEffects
                    playIfNeeded(state, &effects)
                    return .merge(effects)
                case .rewindForward:
                    guard state.audioInfoState.currentTime <= state.audioInfoState.totalDuration else { return .none }
                    
                    if state.audioInfoState.currentTime >= (state.audioInfoState.totalDuration - Constant.rewindForwardTime) {
                        state.audioInfoState.currentTime = state.audioInfoState.totalDuration
                    } else {
                        state.audioInfoState.currentTime += Constant.rewindForwardTime
                    }
                    
                    var effects = defaultCalncelEffects
                    playIfNeeded(state, &effects)
                    
                    return .merge(effects)
                case .changeSpeed:
                    let nextIndex = (state.audioInfoState.currentPlaybackSpeedIndex + 1) % AudioPlayerClient.PlaybackSpeed.allCases.count
                    state.audioInfoState.currentPlaybackSpeed = AudioPlayerClient.PlaybackSpeed.allCases[nextIndex]
                    
                    if state.playerState == .playing {
                        return .merge(
                            .cancel(id: CancelID.play),
                            .run { send in
                                await send(.playerAction(.play))
                            }.cancellable(id: CancelID.play, cancelInFlight: true)
                        )
                    }
                    
                    return .none
                case .didFinishPlaying:
                    var effects = defaultCalncelEffects
                    
                    guard !state.isLastAudio else {
                        state.playerState = .pause
                        return .merge(effects)
                    }
                    
                    state.audioInfoState.currentAudioIndex += 1
                    state.audioInfoState.currentTime = 0
                    state.audioInfoState.totalDuration = 0
                    
                    state.playerState = .pause
                    effects.append(
                        .run { [url = state.book.urls[state.audioInfoState.currentAudioIndex]] send in
                            let duration = try await audioPlayer.totalDuration(url)
                            await send(.getTotalDuration(duration))
                        }
                    )
                    return .merge(effects)
                }
            case .updateCurrentAudioTime:
                guard state.audioInfoState.currentTime <= state.audioInfoState.totalDuration else {
                    return .merge(.cancel(id: CancelID.timer), .cancel(id: CancelID.play))
                }
                
                state.audioInfoState.currentTime += 1
                
                if state.audioInfoState.currentTime >= state.audioInfoState.totalDuration {
                    return .send(.playerAction(.didFinishPlaying))
                }
                
                return .none
            case let .updateSliderProgress(time):
                state.audioInfoState.sliderValue = Double(time)
                
                if state.playerState == .playing {
                    return .merge(
                        .cancel(id: CancelID.play),
                        .run { send in await send(.playerAction(.play)) }
                    )
                }
                
                return .none
            case .startTimer:
                return .run(priority: .high) { send in
                    for await _ in self.clock.timer(interval: .seconds(1)) {
                        await send(.updateCurrentAudioTime)
                    }
                }
                .cancellable(id: CancelID.timer, cancelInFlight: true)
            case let .getTotalDuration(duration):
                state.audioInfoState.totalDuration = duration
                return .none
            case .showText:
                state.shouldPresentText = true
                return .none
            case .hideText:
                state.shouldPresentText = false
                return .none
            }
        }
    }
}

private extension PlayerControlsReducer {
    func playIfNeeded(_ state: PlayerControlsReducer.State, _ effects: inout [Effect<PlayerControlsReducer.Action>]) {
        guard state.playerState == .playing else { return }
        
        let playEffect: Effect<PlayerControlsReducer.Action> = .run { await $0(.playerAction(.play)) }
            .cancellable(id: CancelID.play, cancelInFlight: true)
        
        effects.append(playEffect)
    }
}
