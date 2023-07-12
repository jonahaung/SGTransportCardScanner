//
//  File.swift
//  
//
//  Created by Aung Ko Min on 12/7/23.
//

import Foundation

public enum EZLinkCardProfileType: String {
    case motoring = "Motoring"
}

public struct NFCCard: Codable {
    
    public let can: String
    public let purseBalance: String
    public let purseBalanceInt: UInt64
    public let expiryDate: String
    public let autoloadStatus: String
    public let purseStatus: String
    public let autoloadAmount: String
    public let cardProfile: String
    public let historyRecordNum: UInt8
    public let lastTxn: NFCCardTransaction?
    public let txnHistory: [NFCCardTransaction]?
    
    public var cardStatusFromServer: CardValidityStatus?
    public var profileType: EZLinkCardProfileType?
    
    private enum CodingKeys: String, CodingKey {
        case cardProfile = "card_profile"
        case purseBalanceInt = "int_purse_balance"
        case expiryDate = "expiry_date"
        case lastTxn = "last_txn"
        case purseBalance = "purse_balance"
        case purseStatus = "status"
        case can
        case historyRecordNum = "history_record_num"
        case autoloadStatus = "autoload_status"
        case autoloadAmount = "auloload_amount"
        case txnHistory = "txn_history"
    }
    
    // swiftlint:disable line_length
    internal init(can: String, purseBalance: String, purseBalanceInt: UInt64, expiryDate: String, autoloadStatus: String, purseStatus: String, autoloadAmount: String, cardProfile: String, historyRecordNum: UInt8, lastTxn: NFCCardTransaction?, txnHistory: [NFCCardTransaction]?, cardStatusFromServer: CardValidityStatus? = nil, profileType: EZLinkCardProfileType? = nil) {
        self.can = can
        self.purseBalance = purseBalance
        self.purseBalanceInt = purseBalanceInt
        self.expiryDate = expiryDate
        self.autoloadStatus = autoloadStatus
        self.purseStatus = purseStatus
        self.autoloadAmount = autoloadAmount
        self.cardProfile = cardProfile
        self.historyRecordNum = historyRecordNum
        self.lastTxn = lastTxn
        self.txnHistory = txnHistory
        self.cardStatusFromServer = cardStatusFromServer
        self.profileType = profileType
    }
    
    public init(hexData: Data, txnLogHexData: [Data]) {
        let respStr = hexData.toHex().joined()
        can = respStr.substring(8 * 2, 16 * 2)
        purseBalance = NFCCard.getAmount(temp: respStr.substring(2 * 2, 5 * 2), typeHexStr: "")
        purseBalanceInt = NFCCard.getAmountInt(temp: respStr.substring(2 * 2, 5 * 2), txnType: "")
        expiryDate = NFCCard.getDate(respStr.substring(2 * 24, 2 * 26))
        autoloadStatus = NFCCard.getALStatus(respStr.substring(2 * 1, 2 * 2))
        purseStatus = NFCCard.getPurseStatus(respStr.substring(2 * 1, 2 * 2))
        autoloadAmount = NFCCard.getALAmount(respStr.substring(2 * 1, 2 * 2), respStr.substring(2 * 5, 2 * 8))
        cardProfile = NFCCard.getCardProfile(respStr.substring(2 * 66, 2 * 67))
        historyRecordNum = [UInt8](hexData)[40]
        if !respStr.substring(0, 2).elementsEqual("03") {
            let lastTransactionStr = respStr.substring(2 * 46, 2 * 54)
            let baKeyword: [UInt8] = Array([UInt8](hexData)[46 + 8..<46 + 8 + 8])
            lastTxn = NFCCard.getTxnLog(transactionStr: lastTransactionStr,
                                        userData: baKeyword,
                                        autoloadAmount: autoloadAmount)
        } else {
            lastTxn = nil
        }
        
        if txnLogHexData.count > 0 {
            let ALAmount = NFCCard.getALAmount(respStr.substring(2 * 1, 2 * 2), respStr.substring(2 * 5, 2 * 8))
            txnHistory = txnLogHexData.compactMap { txnLogData -> NFCCardTransaction? in
                guard txnLogData.count >= 16 else { return nil }
                let tnxStr = txnLogData.toHex().joined()
                let baKeyword: [UInt8] = Array([UInt8](txnLogData)[8..<16])
                return NFCCard.getTxnLog(transactionStr: tnxStr,
                                         userData: baKeyword,
                                         autoloadAmount: ALAmount)
            }
        } else {
            txnHistory = nil
        }
    }
}

public extension NFCCard {
    static func getAmount(temp: String, typeHexStr: String) -> String {
        if typeHexStr.hasPrefix("F0") // miscellaneous txn
            || typeHexStr.hasPrefix("83") // purse diable txn
            || typeHexStr.hasPrefix("11") { // autoload disable txn
            return "N.A."
        }
        if temp.hasPrefix("0") {
            var index = 0
            while index < temp.count - 1 {
                if temp.substring(index, index+1).first == "0" {
                    index += 1
                } else {
                    break
                }
            }
            if let j = UInt64(temp.substring(index), radix: 16),
               let result = NSNumber(value: Double(j) * 0.01).currencyFormat() {
                return result
            } else {
                return "N.A."
            }
        } else {
            let max = UInt64("FFFFFF", radix: 16)!
            guard let min = UInt64(temp, radix: 16) else {
                return ""
            }
            let bal = max - min + 1
            return "-" + (NSNumber(value: Double(bal) * 0.01).currencyFormat() ?? "")
        }
    }
    
    static func getAmountInt(temp: String, txnType: String) -> UInt64 {
        if txnType.hasPrefix("F0") // miscellaneous txn
            || txnType.hasPrefix("83") // purse diable txn
            || txnType.hasPrefix("11") { // autoload disable txn
            return 0
        }
        
        if temp.hasPrefix("0") {
            var index = 0
            while index < temp.count - 1 {
                if temp.substring(index, index+1).first == "0" {
                    index += 1
                } else {
                    break
                }
            }
            if let j = UInt64(temp.substring(index), radix: 16) {
                return j
            } else {
                return 0
            }
        } else {
            let max = UInt64("FFFFFF", radix: 16)!
            guard let min = UInt64(temp, radix: 16) else {
                return 0
            }
            let bal = max - min + 1
            return bal
        }
    }
    
    static func getDate(_ temp: String) -> String {
        guard let j = UInt64(temp, radix: 16) else { return "" }
        // added seconds between 1995 and 1970
        let seconds: TimeInterval = (Double(j) + 9131) * 86400
        let date = Date(timeIntervalSince1970: seconds)
        let format = DateFormatter()
        format.dateFormat = "dd/MM/yyyy"
        return format.string(from: date)
    }
    
    static func getDateTime(_ temp: String) -> String {
        guard let j = UInt64(temp, radix: 16) else { return "" }
        // added seconds between 1995 and 1970
        // then minused 8 hours
        let seconds: TimeInterval = Double(j) + 9131 * 86400 - (8 * 60 * 60)
        let date = Date(timeIntervalSince1970: seconds)
        let format = DateFormatter()
        format.dateFormat = "dd/MM/yyyy HH:mm:ss"
        return format.string(from: date)
    }
    
    static func getALStatus(_ temp: String) -> String {
        guard let j = UInt8(temp, radix: 16) else { return "" }
        if j&0x01 == 0 {
            return "N.A."
        }
        if j&0x02 == 0 {
            return "Not Enabled"
        }
        return "Enabled"
    }
    
    static func getPurseStatus(_ temp: String) -> String {
        guard let j = UInt8(temp, radix: 16) else { return "" }
        if j&0x01 == 0 {
            return "Not Enabled"
        }
        return "Enabled"
    }
    
    static func getALAmount(_ purseStatus: String, _ amt: String) -> String {
        guard let j = UInt8(purseStatus, radix: 16) else { return "" }
        if j&0x01 == 0 {
            return "N.A."
        }
        if j&0x02 == 0 {
            return "N.A."
        }
        return getAmount(temp: amt, typeHexStr: "")
    }
    
    static func getTypeString(_ typeStr: String) -> String {
        if typeStr.hasSuffix("A0") {
            return "Retail Payment"
        } else if typeStr.hasSuffix("F0") {
            return "Miscellaneous"
        } else if typeStr.hasSuffix("87") {
            return "Bus Refund with AL Disable"
        } else if typeStr.hasSuffix("86") {
            return "Bus Payment with AL Disable"
        } else if typeStr.hasSuffix("85") {
            return "Rail Payment with AL Disable"
        } else if typeStr.hasSuffix("84") {
            return "Purse and AL Disable"
        } else if typeStr.hasSuffix("83") {
            return "AL Disable"
        } else if typeStr.hasSuffix("76") {
            return "Bus Refund"
        } else if typeStr.hasSuffix("75") {
            return "Add Value"
        } else if typeStr.hasSuffix("66") {
            return "Cash back"
        } else if typeStr.hasSuffix("3B") {
            return "VEP Payment"
        } else if typeStr.hasSuffix("32") {
            return "EZL Debit"
        } else if typeStr.hasSuffix("31") {
            return "Bus Payment"
        } else if typeStr.hasSuffix("30") {
            return "Rail Payment"
        } else if typeStr.hasSuffix("11") {
            return "Purse Disable"
        } else if typeStr.hasSuffix("09") {
            return "EPS TBC (Time Based Charging)"
        } else if typeStr.hasSuffix("08") {
            return "ERP DBC (Distance Based Charging)"
        } else if typeStr.hasSuffix("07") {
            return "ERP CBC (Congestion Based Charging)"
        } else {
            return typeStr
        }
    }
    
    static func getCharFromHex(_ bytes: [UInt8]) -> String {
        return String(bytes: bytes, encoding: .ascii) ?? ""
    }
    
    static func getCardProfile(_ purseStatus: String) -> String {
        guard let j = UInt8(purseStatus, radix: 16) else { return "" }
        // let cardRefundStatus = j >> 6 & 0x03
        let cardProfileType = j & 0x3f
        return "\(cardProfileType)"
    }
    
    static func ERPCBC(_ userData: [UInt8]) -> String {
        guard userData.count == 8 else {
            return ""
        }
        return Array(userData[4...5])
            .map { String($0, radix: 16, uppercase: true) }
            .map { $0.count == 1 ? "0\($0)" : $0 }
            .joined()
    }
    
    static func EPSTBC(_ userData: [UInt8]) -> String {
        guard userData.count == 8 else {
            return ""
        }
        return Array(userData[3...4])
            .map { String($0, radix: 16, uppercase: true) }
            .map { $0.count == 1 ? "0\($0)" : $0 }
            .joined()
    }
    
    static func getTxnLog(transactionStr: String, userData: [UInt8], autoloadAmount: String) -> NFCCardTransaction? {
        guard !transactionStr.hasPrefix("00000000") else { return nil }
        let typeHexStr = transactionStr.substring(0, 2)
        let txnType = getTypeString(typeHexStr)
        let txnAmt = getAmount(temp: transactionStr.substring(2, 2 * 4), typeHexStr: typeHexStr)
        
        let dateStr = transactionStr.substring(2 * 4, 2 * 8)
        let txnDatetime = getDateTime(dateStr)
        let txnUserData: String = {
            let char = getCharFromHex(userData)
            if typeHexStr.hasSuffix("07") { // ERP CBC
                return ERPCBC(userData)
            } else if typeHexStr.hasSuffix("08") { // ERP DBC
                return char
            } else if typeHexStr.hasSuffix("09") {
                return EPSTBC(userData)
            }
            return char
        }()
        let txnALAmt: String
        if userData[7]&0x01 == 1 { // auto load
            txnALAmt = autoloadAmount
        } else {
            txnALAmt = "$0.00"
        }
        
        return NFCCardTransaction(txnType: txnType,
                                  txnAmt: txnAmt,
                                  txnDatetime: txnDatetime,
                                  txnUserData: txnUserData,
                                  txnALAmt: txnALAmt)
    }
    
    static func getTxnHistory(historyRecordNum: UInt8) -> [NFCCardTransaction]? {
        guard historyRecordNum > 0 else { return nil }
        
        return nil
    }
}

public extension NFCCard {
    
    var formattedCan: String { can.formattedCardNumber }
    var formattedBalance: String { purseBalance }
    var formattedExpireDate: String { expiryDate }
    var status: CardValidityStatus {
        return cardStatusFromServer ??
        (purseStatus == "Enabled" ? CardValidityStatus.notBlocked : CardValidityStatus.blocked)
    }
    var isExpired: Bool {
        var config = DatePickConfig.default
        guard let date = config.dateFormatterForDisplay.date(from: expiryDate) else {
            return false
        }
        return date.timeIntervalSince1970 < Date().timeIntervalSince1970
    }
    var isCCCard: Bool { EZLinkCardType.isConcessionCard(can) }
    var type: EZLinkCardType { return .CBT }
    var balanceStatus: EZLinkCardBalanceStatus {
        if purseBalanceInt <= 0 {
            return .OVERDUE
        } else if purseBalanceInt < 300 {
            return .LIMITED
        } else {
            return .SUFFICENT
        }
    }
    var cardProfileType: EZLinkCardProfileType? { profileType }
}


public enum EZLinkCardType: String {
    
    case ABT
    case CBT
    
    /// Identify whether an ez-link card is a concession card or not
    static func isConcessionCard(_ canId: String) -> Bool {
        guard canId.count >= 4 else {
            return false
        }
        let fourNumber = Int(canId.getSubStringByStart(offset: 3)) ?? 0
        return fourNumber >= 8000 && fourNumber <= 8009
    }
    
    static func isNetsCard(_ canId: String) -> Bool {
        let fourNumber = Int(canId.components(separatedBy: " ")[0]) ?? 0
        return fourNumber >= 1111 && fourNumber <= 1120
    }
    
    static func isABTCCCard(canId: String, cardType: String) -> Bool {
        guard canId.isConcessionCard, let aCardType = EZLinkCardType(rawValue: cardType),
              aCardType == .ABT else { return false }
        return true
    }
    
    func isCBTDefault(canId: String) -> Bool {
        guard self == .CBT else { return false }
        switch CardVariety(canId: canId) {
        case .defalut(let isEzMotoringCard) where isEzMotoringCard == false:
            return true
        default:
            return false
        }
    }
}
