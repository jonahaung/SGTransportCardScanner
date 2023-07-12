//
//  File.swift
//  
//
//  Created by Aung Ko Min on 12/7/23.
//

import Foundation

public protocol TransportCardProtocol {
    var canId: String { get }
    var cardName: String { get set }
    var cardStatus: String { get }
    var expiryDate: String { get }
    var availableBalance: String { get set }
    var autoTopUp: Bool { get }
    var expired: Bool { get }
    var statusMessage: String { get }
    var caseSubtype: String { get }
    var reportDate: String { get }
    var estimatedFare: String { get set }
    var type: EZLinkCardType { get }
    var balanceStatus: EZLinkCardBalanceStatus { get set }
    var hasIncompleteSyncStatus: Bool { get }
    var syncStatus: String? { get set }
    var syncAmount: String? { get set }
    var syncStartTime: String? { get set }
    var tappable: Bool { get }
    var _belongsToUser: Bool? { get }
    var cardProfileType: EZLinkCardProfileType? { get }
}

public extension TransportCardProtocol {
    var cardType: String {
        return type.rawValue
    }
    
    var belongsToUser: Bool? {
        if EZLinkCardType.isABTCCCard(canId: canId, cardType: type.rawValue) {
            return _belongsToUser
        }
        return true
    }
}
