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
    @Dependency(\.audioPlayer) private var audioPlayer
    @Dependency(\.continuousClock) private var clock
    
    private enum CancelID {
        case play
        case timer
    }
    
    struct State: Equatable {
        var bookID: Book.Identifier
        var book: Book = .empty
        var playerState: PlayerState = .pause
        var audioInfoState: AudioInfoState = .empty
    }
    
    enum Action: Equatable {
        case onAppear
        case startTimer
        case updateCurrentAudioTime
        case updateSliderProgress(Float)
        case getTotalDuration(TimeInterval)
        
        case bookFetched(Book)
        case playerAction(PlayerAction)
    }
    
    var body: some Reducer<State, Action> {
        let defaultCalncelEffects: [Effect<BookDetailsReducer.Action>] = [
            .cancel(id: CancelID.play),
            .cancel(id: CancelID.timer)
        ]
        
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
                let index = state.audioInfoState.currentAudioIndex
                
                return .run { send in
                    let duration = try await audioPlayer.totalDuration(book.urls[index])
                    await send.callAsFunction(.getTotalDuration(duration))
                }
            case let .playerAction(action):
                switch action {
                case .play:
                    state.playerState = .playing
                    let time = state.audioInfoState.currentTime
                    let speed = state.audioInfoState.currentPlaybackSpeed
                    return .run(priority: .high) { [url = state.book.urls[state.audioInfoState.currentAudioIndex]] send in
                        await send(.startTimer)
                        
                        _ = try await audioPlayer.control(url, .play(time, speed))
                    }
                    .cancellable(id: CancelID.play, cancelInFlight: true)
                case .pause:
                    state.playerState = .pause
                    return .merge(.cancel(id: CancelID.play), .cancel(id: CancelID.timer))
                case .back:
                    guard !state.isFirstAudio else { return .none }
                    var effects = defaultCalncelEffects
                    let url = state.book.urls[state.audioInfoState.currentAudioIndex]
                    effects.append(
                        .run { send in
                            let duration = try await audioPlayer.totalDuration(url)
                            await send(.getTotalDuration(duration))
                        }
                    )
                    
                    state.audioInfoState.currentAudioIndex -= 1
                    state.audioInfoState.currentTime = 0
                    
                    playIfNeeded(state, &effects)
                    return .merge(effects)
                case .next:
                    guard !state.isLastAudio else { return .none }
                    var effects = defaultCalncelEffects
                    let url = state.book.urls[state.audioInfoState.currentAudioIndex]
                    effects.append(
                        .run { send in
                            let duration = try await audioPlayer.totalDuration(url)
                            await send(.getTotalDuration(duration))
                        }
                    )
                    state.audioInfoState.currentAudioIndex += 1
                    state.audioInfoState.currentTime = 0
                    
                    playIfNeeded(state, &effects)
                    return .merge(effects)
                    
                case .goBack5:
                    guard state.audioInfoState.currentTime != 0 else { return .none }
                    if state.audioInfoState.currentTime <= 5 {
                        state.audioInfoState.currentTime = 0
                    } else {
                        state.audioInfoState.currentTime -= 5
                    }
                    
                    var effects = defaultCalncelEffects
                    playIfNeeded(state, &effects)
                    return .merge(effects)
                case .goForward10:
                    guard state.audioInfoState.currentTime <= state.audioInfoState.totalDuration else { return .none }
                    
                    if state.audioInfoState.currentTime >= (state.audioInfoState.totalDuration - 10) {
                        state.audioInfoState.currentTime = state.audioInfoState.totalDuration
                    } else {
                        state.audioInfoState.currentTime += 10
                    }
                    
                    var effects = defaultCalncelEffects
                    playIfNeeded(state, &effects)
                    
                    return .merge(effects)
                case .changeSpeed:
                    let nextIndex = (state.audioInfoState.currentPlaybackSpeedIndex + 1) % AudioPlayerClient.PlaybackSpeed.allCases.count
                    state.audioInfoState.currentPlaybackSpeed = AudioPlayerClient.PlaybackSpeed.allCases[nextIndex]
                    
                    switch state.playerState {
                    case .pause:
                        return .none
                    case .playing:
                        return .merge(
                            .cancel(id: CancelID.play),
                            .run { send in
                                await send(.playerAction(.play))
                            }.cancellable(id: CancelID.play, cancelInFlight: true)
                        )
                    }
                case .didFinishPlaying:
                    var effects = defaultCalncelEffects
                    
                    guard !state.isLastAudio else {
                        state.playerState = .pause
                        return .merge(effects)
                    }
                    
                    state.audioInfoState.currentAudioIndex += 1
                    state.audioInfoState.currentTime = 0
                    state.playerState = .pause
                    
                    let url = state.book.urls[state.audioInfoState.currentAudioIndex]
                    effects.append(
                        .run { send in
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
            }
        }
    }
}

private extension BookDetailsReducer {
    func playIfNeeded(_ state: BookDetailsReducer.State, _ effects: inout [Effect<BookDetailsReducer.Action>]) {
        guard state.playerState == .playing else { return }
        
        let playEffect: Effect<BookDetailsReducer.Action> = .run { await $0(.playerAction(.play)) }
            .cancellable(id: CancelID.play, cancelInFlight: true)
        
        effects.append(playEffect)
    }
}
