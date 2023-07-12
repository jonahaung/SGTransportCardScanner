//
//  File.swift
//  
//
//  Created by Aung Ko Min on 12/7/23.
//

import Foundation
enum ATUStatus: String, Codable {
    case pendingActivation = "Pending Activation"
    case activated = "Activated"
    case pendingDeactivation = "Pending Deactivation"
    case deactivated = "Deactivated"
    case suspend = "Suspend"
    case unregistered = "Unregistered"
    case limited = "Limited"
    case unknown
    init(status: String) {
        switch status {
        case "Activated":
            self = ATUStatus.activated
        case "Pending Activation":
            self = ATUStatus.pendingActivation
        case "Pending Deactivation":
            self = ATUStatus.pendingDeactivation
        case "Deactivated":
            self = ATUStatus.deactivated
        case "Suspend":
            self = ATUStatus.suspend
        case "Unregistered":
            self = ATUStatus.unregistered
        case "Limited":
            self = ATUStatus.limited
        default:
            self = ATUStatus.unknown
        }
    }
}
