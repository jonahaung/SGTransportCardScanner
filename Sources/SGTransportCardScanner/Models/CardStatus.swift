//
//  File.swift
//  
//
//  Created by Aung Ko Min on 12/7/23.
//

import Foundation

public enum CardValidityStatus: String {
    case notBlocked = "normal"
    case blocked = "blocked"
    case pendingBlock = "pending block"
    
    var shouldShowBanner: Bool {
        switch self {
        case .blocked, .pendingBlock: return true
        case .notBlocked: return false
        }
    }
}

enum CardStatus: Int {
    case active = 0
    case inactive = 1
}


public enum EZLinkCardBalanceStatus: String {
    case OVERDUE
    case LIMITED
    case SUFFICENT
}
