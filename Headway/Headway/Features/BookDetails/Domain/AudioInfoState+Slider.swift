//
//  AudioInfoState+Slider.swift
//  Headway
//
//  Created by Hlib Serediuk-Personal on 25.12.2023.
//

typealias AudioInfoState = BookDetailsReducer.State.AudioInfoState

extension BookDetailsReducer.State.AudioInfoState {
    static let sliderStep: ClosedRange<Float> = 0...1
    
    var sliderValue: Double {
        get {
            guard totalDuration > 0 else { return 0 }
            return currentTime / totalDuration
        }
        set {
            currentTime = newValue * totalDuration
        }
    }
}
