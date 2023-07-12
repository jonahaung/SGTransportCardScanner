//
//  File.swift
//  
//
//  Created by Aung Ko Min on 12/7/23.
//

import Foundation

public struct NFCCardTransaction: Codable {
    public let txnType: String
    public let txnAmt: String
    public let txnDatetime: String
    public let txnUserData: String
    public let txnALAmt: String
    
    private enum CodingKeys: String, CodingKey {
            case txnAmt = "txn_amt"
            case txnDatetime = "txn_datetime"
            case txnALAmt = "txn_a_l_amt"
            case txnUserData = "txn_user_data"
            case txnType = "txn_type"
    }
}
