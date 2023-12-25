//
//  AudioPlayerClient.swift
//  Headway
//
//  Created by Hlib Serediuk-Personal on 23.12.2023.
//

import AVFoundation
import Dependencies

struct AudioPlayerClient {
    var control: (_ audioURL: URL, _ action: AudioPlayerClient.Action) async throws -> Bool
    var totalDuration: (_ audioURL: URL) async throws -> TimeInterval
}

extension AudioPlayerClient: DependencyKey {
    static var liveValue = Self { url, action  in
        let stream = AsyncThrowingStream<Bool, Error> { continuation in
            
            do {
                let delegate = try Delegate(url: url)
                
                switch action {
                case let .play(time, speed):
                    delegate.player.pause()
                    delegate.player.currentTime = time
                    delegate.player.enableRate = true
                    delegate.player.rate = speed.rawValue
                    
                    delegate.player.prepareToPlay()
                    delegate.player.play()
                }
                continuation.onTermination = { _ in
                    delegate.player.stop()
                }
            } catch {
                continuation.finish(throwing: error)
            }
        }
        
        return try await stream.first(where: { _ in true }) ?? false
    } totalDuration: { url in
        let delegate = try Delegate(url: url)
        
        return delegate.player.duration
    }
}

// MARK: - Dependency

extension DependencyValues {
    var audioPlayer: AudioPlayerClient {
        get { self[AudioPlayerClient.self] }
        set { self[AudioPlayerClient.self] = newValue }
    }
}

private final class Delegate: NSObject, AVAudioPlayerDelegate {
    let player: AVAudioPlayer
    
    init(url: URL) throws {
        self.player = try AVAudioPlayer(contentsOf: url)
        super.init()
        self.player.delegate = self
    }
}
