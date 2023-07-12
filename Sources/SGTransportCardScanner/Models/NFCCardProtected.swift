//
//  File.swift
//  
//
//  Created by Aung Ko Min on 12/7/23.
//

import Foundation
public struct NFCCardProtected: Codable {
    let cardRandom: String
    let terminalRandom: String
    let purseData: String
    private enum CodingKeys: String, CodingKey {
        case cardRandom = "card_random"
        case terminalRandom = "terminal_random"
        case purseData = "purse_data"
    }
}
