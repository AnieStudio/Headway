//
//  TimeInterval+Extensions.swift
//  Headway
//
//  Created by Hlib Serediuk-Personal on 24.12.2023.
//

import Foundation

extension TimeInterval {
    var toMMSS: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
