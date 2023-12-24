//
//  BookDetailsReducer.swift
//  Headway
//
//  Created by Hlib Serediuk-Personal on 23.12.2023.
//

import SwiftUI
import ComposableArchitecture
import Foundation

private struct FetchBookID: Hashable {}
private struct FetchImageID: Hashable {}

struct BookDetailsReducer: Reducer {
    @Dependency(\.bookDetailsRepository) var bookDetailsRepository
    @Dependency(\.audioPlayer) var audioPlayer
    @Dependency(\.continuousClock) var clock
    
    private enum CancelID {
        case play
        case pause
        case timer
        case updateProgress
    }
    
    struct State: Equatable {
        var bookID: Book.Identifier
        var book: Book = .empty
        var playerState: PlayerState = .pause
        var currentAudioIndex: Int = 0
        var audioInfoState: AudioInfoState = .empty
        
        var isLastAudio: Bool {
            currentAudioIndex == (book.urls.count - 1)
        }
        
        var isFirstAudio: Bool {
            currentAudioIndex == 0
        }
        
        var currentChapterNote: String {
            guard book != .empty else { return "" }
            
            return book.playlist.audio[currentAudioIndex].notes
        }
        
        enum PlayerState: Equatable {
            case playing
            case pause
        }
        
        struct AudioInfoState: Equatable {
            var currentTime: TimeInterval = 0
            var totalDuration: TimeInterval = 0
            var currentSliderValue: Float = 0
            var currentPlaybackSpeed: AudioPlayerClient.PlaybackSpeed = .normal
            var sliderStep: ClosedRange<Float> = 0...1
            
            var currentPlaybackSpeedDescr: String {
                currentPlaybackSpeed.description
            }
            
            var sliderValue: Double {
                   get {
                       guard totalDuration > 0 else { return 0 }
                       return currentTime / totalDuration
                   }
                   set {
                       currentTime = newValue * totalDuration
                   }
               }
            
            var currentPlaybackSpeedIndex: Int {
                AudioPlayerClient.PlaybackSpeed.allCases.firstIndex(of: currentPlaybackSpeed) ?? 2
            }
            
            var currentProgress: Float {
                Float(totalDuration > 0 ? currentTime / totalDuration : 0)
            }
            
            static let empty: Self = .init(currentTime: 0, totalDuration: 0)
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case updateCurrentTime
        case updateProgress(Float)
        
        case bookFetched(TaskResult<Book>)
        case playerAction(PlayerAction)
        case timerAction(TimeAction)
        case audioInfoAction(AudioInfoAction)
        
        enum TimeAction: Equatable {
            case start
            case pause
        }
        
        enum AudioInfoAction: Equatable {
            case getTotalDuration(TimeInterval)
            case didUpdateSliderValue(Float)
        }
        
        enum PlayerAction: Equatable {
            case play
            case pause
            case back
            case next
            case goBack5
            case goForward10
            case changeSpeed
            case didFinishPlaying
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let id = state.bookID
                
                return .run { send in
                    Task {
                        do {
                            let book = try await bookDetailsRepository.book(id)
                            await send.callAsFunction(.bookFetched(.success(book)))
                            
                        } catch {
                            await send(.bookFetched(.failure(error)))
                        }
                    }
                }
                .cancellable(id: FetchBookID(), cancelInFlight: true)
                
            case let .bookFetched(result):
                switch result {
                case let .failure(error):
                    print("Error \(error)")
                    return .none
                case let .success(book):
                    state.book = book
                    
                    let index = state.currentAudioIndex
                    return .run { send in
                        let duration = try await audioPlayer.totalDuration(book.urls[index])
                        await send.callAsFunction(.audioInfoAction(.getTotalDuration(duration)))
                    }
                }
            case let .playerAction(action):
                switch action {
                case .play:
                    state.playerState = .playing
                    let time = state.audioInfoState.currentTime
                    let speed = state.audioInfoState.currentPlaybackSpeed
                    return .run(priority: .high) { [url = state.book.urls[state.currentAudioIndex]] send in
                        await send(.timerAction(.start))
                        
                        _ = try await audioPlayer.control(url, .play(time, speed))
                    }
                    .cancellable(id: CancelID.play, cancelInFlight: true)
                case .pause:
                    state.playerState = .pause
                    return .merge(.cancel(id: CancelID.play), .cancel(id: CancelID.timer))
//                    return .run(priority: .high) { [url = state.book.urls[state.currentAudioIndex]] send in
//                        await send(.timerAction(.pause))
//                        _ = try await audioPlayer.control(url, .pause)
//                    }
//                    .cancellable(id: CancelID.play, cancelInFlight: true)
                    
                case .back:
                    guard !state.isFirstAudio else { return .none }
                    
                    let url = state.book.urls[state.currentAudioIndex]
                    var effects: [Effect<BookDetailsReducer.Action>] = [
                        .cancel(id: CancelID.play),
                        .cancel(id: CancelID.timer),
                        .run { send in
                            let duration = try await audioPlayer.totalDuration(url)
                            await send(.audioInfoAction(.getTotalDuration(duration)))
                        }
                    ]
                    
                    state.currentAudioIndex -= 1
                    state.audioInfoState.currentTime = 0
                    state.audioInfoState.currentSliderValue = 0.0
                    
                    if state.playerState == .playing {
                        effects.append(
                            .run { send in
                                await send(.playerAction(.play))
                            }.cancellable(id: CancelID.play, cancelInFlight: true)
                        )
                    }
                    return .merge(effects)
                case .next:
                    guard !state.isLastAudio else { return .none }
                    
                    let url = state.book.urls[state.currentAudioIndex]
                    var effects: [Effect<BookDetailsReducer.Action>] = [
                        .cancel(id: CancelID.play),
                        .cancel(id: CancelID.timer),
                        .run { send in
                            let duration = try await audioPlayer.totalDuration(url)
                            await send(.audioInfoAction(.getTotalDuration(duration)))
                        }
                    ]
                    
                    state.currentAudioIndex += 1
                    state.audioInfoState.currentTime = 0
                    state.audioInfoState.currentSliderValue = 0.0
                                        
                    if state.playerState == .playing {
                        effects.append(
                            .run { send in
                                await send(.playerAction(.play))
                            }.cancellable(id: CancelID.play, cancelInFlight: true)
                        )
                    }
                    return .merge(effects)
                    
                case .goBack5:
                    guard state.audioInfoState.currentTime != 0 else { return .none }
                    if state.audioInfoState.currentTime <= 5 {
                        state.audioInfoState.currentTime = 0
                    } else {
                        state.audioInfoState.currentTime -= 5
                    }
                    
                    print("--->  timer \(state.audioInfoState.currentTime)")
                    
                    var effects: [Effect<BookDetailsReducer.Action>] = [
                        .cancel(id: CancelID.play)
                    ]
                    if state.playerState == .playing {
                        effects.append(
                            .run { send in
                                await send(.playerAction(.play))
                            }.cancellable(id: CancelID.play, cancelInFlight: true)
                        )
                    }
                    return .merge(effects)
                case .goForward10:
                   guard state.audioInfoState.currentTime <= state.audioInfoState.totalDuration else { return .none }
                    
                    if state.audioInfoState.currentTime >= (state.audioInfoState.totalDuration - 10) {
                        state.audioInfoState.currentTime = state.audioInfoState.totalDuration
                    } else {
                        state.audioInfoState.currentTime += 10
                    }
                    print("---> Timer \(state.audioInfoState.currentTime)")
                    
                    var effects: [Effect<BookDetailsReducer.Action>] = [
                        .concatenate(.cancel(id: CancelID.play))
                    ]
                    if state.playerState == .playing {
                        effects.append(
                            .run { send in
                                await send(.playerAction(.play))
                            }.cancellable(id: CancelID.play, cancelInFlight: true)
                        )
                    }
                    
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
                    var effects: [Effect<BookDetailsReducer.Action>] = [
                        .cancel(id: CancelID.play),
                        .cancel(id: CancelID.timer),
                    ]
                    
                    guard !state.isLastAudio else {
                        state.playerState = .pause
                        return .merge(effects)
                    }
                    
                    state.currentAudioIndex += 1
                    state.audioInfoState.currentTime = 0
                    state.audioInfoState.currentSliderValue = 0.0
                    state.playerState = .pause
                    
                    let url = state.book.urls[state.currentAudioIndex]
                    effects.append(
                        .run { send in
                            let duration = try await audioPlayer.totalDuration(url)
                            await send(.audioInfoAction(.getTotalDuration(duration)))
                        }
                    )
                    return .merge(effects)
                }
            case .updateCurrentTime:
                guard state.audioInfoState.currentTime <= state.audioInfoState.totalDuration else {
                    return .merge(.cancel(id: CancelID.timer), .cancel(id: CancelID.play))
                }
                
                state.audioInfoState.currentTime += 1
                
                if state.audioInfoState.currentTime >= state.audioInfoState.totalDuration {
                    return .send(.playerAction(.didFinishPlaying))
                }
                
                print("--->  Timer \(state.audioInfoState.currentTime)")
                return .none
                
            case let .updateProgress(time):
                state.audioInfoState.sliderValue = Double(time)
                
                if state.playerState == .playing {
                    return .merge(
                        .cancel(id: CancelID.play),
                        .run { send in
                            await send(.playerAction(.play))
                        }
                    )
                    
                }
                
                print("--->  Timer \(state.audioInfoState.currentTime)")
                return .none
            case let .timerAction(timerAction):
                switch timerAction {
                case .start:
                    return .run(priority: .high) { send in
                        for await _ in self.clock.timer(interval: .seconds(1)) {
                            await send(.updateCurrentTime)
                        }
                    }
                    .cancellable(id: CancelID.timer, cancelInFlight: true)
                    
                case .pause:
                    return .cancel(id: CancelID.timer)
                }
            case let .audioInfoAction(audioInfoAction):
                switch audioInfoAction {
                case let .getTotalDuration(duration):
                    state.audioInfoState.totalDuration = duration
                    return .none
                case let .didUpdateSliderValue(value):
                    state.audioInfoState.currentSliderValue = value
                    return .none
                }
            }
        }
    }
}
