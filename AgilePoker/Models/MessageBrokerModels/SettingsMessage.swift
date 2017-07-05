//
//  SettingsMessage.swift
//  AgilePoker
//
//  Created by Astro on 7/4/17.
//  Copyright © 2017 Rock Solid Bits. All rights reserved.
//

import Foundation

enum SettingsMessage : Message {
    
    case backgroundImageIndex(Int)
    case deckIndex(Int)
    
    static let backgroundImageIndexType = "backgroundImageIndexType"
    static let deckIndexType = "deckIndexType"
    
    func messageKey() -> MessageKey {
        switch self {
        case .backgroundImageIndex(_):
            return SettingsMessage.backgroundImageIndexType
        case .deckIndex(_):
            return SettingsMessage.deckIndexType
        }
    }
}
