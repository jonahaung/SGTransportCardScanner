//
//  File.swift
//  
//
//  Created by Aung Ko Min on 12/7/23.
//

import Foundation

public enum CardVariety {
    case smrt
    case unlimited
    case liveFresh
    case everyday
    case dbsyog
    case dbssutd
    case icbc
    case fevo
    case passion
    case defalut(isEzMotoringCard: Bool)
    
    init(canId: String, cardProfileType: EZLinkCardProfileType? = nil) {
        if canId <= "1009309999999999" && canId >= "1009300000000000" {
            self = .smrt
        } else if canId <= "1009459999999999" && canId >= "1009450000000000" {
            self = .unlimited
        } else if canId <= "1009609999999999" && canId >= "1009600000000000" {
            self = .liveFresh
        } else if canId <= "1009619999999999" && canId >= "1009610000000000" {
            self = .dbsyog
        } else if canId <= "1009629999999999" && canId >= "1009620000000000" {
            self = .everyday
        } else if canId <= "1009659999999999" && canId >= "1009650000000000" {
            self = .dbssutd
        } else if canId <= "1009679999999999" && canId >= "1009670000000000" {
            self = .icbc
        } else if canId <= "1009709999999999" && canId >= "1009700000000000" {
            self = .fevo
        } else if canId <= "1009729999999999" && canId >= "1009710000000000" {
            self = .passion
        } else if canId <= "1000150015075249" && canId >= "1000150013065250" {
            self = .passion
        } else {
            //            if (canId <= "1008303009999999" && canId >= "1008303000000000") ||
            //                (canId <= "1008304009999999" && canId >= "1008304000000000") {
            if cardProfileType == .motoring {
                self = .defalut(isEzMotoringCard: true)
            } else {
                self = .defalut(isEzMotoringCard: false)
            }
        }
    }
}

//UI Specific
public extension CardVariety {
    var showRetailIcon: Bool {
        switch self {
        case .defalut(let isEzMotoringCard):
            return !isEzMotoringCard
        default:
            return false
        }
    }
    
    var showTransitIcon: Bool {
        switch self {
        case .defalut(let isEzMotoringCard):
            return !isEzMotoringCard
        default:
            return false
        }
    }
    
    var showMotoringIcon: Bool {
        switch self {
        case .defalut:
            return true
        default:
            return false
        }
    }
    
    var showMotoringOnlyLabel: Bool {
        switch self {
        case .defalut(let isEzMotoringCard):
            return isEzMotoringCard
        default:
            return false
        }
    }
}
