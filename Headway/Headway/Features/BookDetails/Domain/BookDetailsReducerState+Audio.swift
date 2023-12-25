//
//  BookDetailsReducerState+Book.swift
//  Headway
//
//  Created by Hlib Serediuk-Personal on 25.12.2023.
//

extension BookDetailsReducer.State {
    var isLastAudio: Bool {
        audioInfoState.currentAudioIndex == (book.urls.count - 1)
    }
    
    var isFirstAudio: Bool {
        audioInfoState.currentAudioIndex == 0
    }
    
    var currentChapterNote: String {
        guard book != .empty else { return "" }
        
        return book.playlist.audio[audioInfoState.currentAudioIndex].notes
    }
}

extension PlayerControlsReducer.State {
    var isLastAudio: Bool {
        audioInfoState.currentAudioIndex == (book.urls.count - 1)
    }
    
    var isFirstAudio: Bool {
        audioInfoState.currentAudioIndex == 0
    }
    
    var currentChapterNote: String {
        guard book != .empty else { return "" }
        
        return book.playlist.audio[audioInfoState.currentAudioIndex].notes
    }
}
