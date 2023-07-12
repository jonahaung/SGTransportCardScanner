//
//  File.swift
//  
//
//  Created by Aung Ko Min on 12/7/23.
//

import Foundation
import CoreNFC

protocol NFCCommandSending {}

extension NFCCommandSending {
    
    typealias CommandResp = Result<(resp: Data, sw1: String, sw2: String), Error>
    
    func sendCommand(_ tag: NFCISO7816Tag, apdu: String, completion: @escaping (CommandResp) -> Void) {
        tag.sendCommand(apdu: apdu) { result in
            completion(result)
        }
    }
    
    func sendCommand(_ tag: NFCISO7816Tag, cls: UInt8, code: UInt8, p1: UInt8, p2: UInt8, dataHexStr: String?, responseLength: Int, completion:  @escaping (CommandResp) -> Void) {
        tag.sendCommand(cls: cls, code: code, p1: p1, p2: p2, dataHexStr: dataHexStr, responseLength: responseLength) { (result) in
            completion(result)
        }
    }
    
    func getChallenge(_ tag: NFCISO7816Tag, completion:  @escaping (String) -> Void) {
        sendCommand(tag, cls: 0x00, code: 0x84, p1: 0x00, p2: 0x00, dataHexStr: nil, responseLength: 08, completion: { result in
            guard case .success(let data) = result, data.resp.count > 0 else {
                return
            }
            completion(data.resp.toHex().joined())
        })
    }
    
    func fetchSecPurseCommand(canId: String, challenge: String,  completion: (String) -> Void) {
        
    }
    
    func getSecPurse(_ tag: NFCISO7816Tag, apdu: String, completion:  @escaping (String) -> Void) {
        sendCommand(tag, apdu: apdu) { result in
            guard case .success(let data) = result, data.resp.count > 0 else {
                return
            }
            completion(data.resp.toHex().joined())
        }
    }
    
    func getCardDetail(_ tag: NFCISO7816Tag, completion:  @escaping (NFCCard) -> Void) {
        sendCommand(tag, apdu: "9032030000") { result in
            guard case .success(let data) = result, data.resp.count > 0 else {
                return
            }
            let details = NFCCard(hexData: data.resp, txnLogHexData: [])
            completion(details)
        }
    }
    
    func getCardDetailWithTxnRecord(_ tag: NFCISO7816Tag, completion:  @escaping (NFCCard) -> Void) {
        sendCommand(tag, apdu: "9032030000") { result in
            guard case .success(let data) = result, data.resp.count > 0  else {
                print(NFCTapError.getPurseFailed)
                return
            }
            var txnLogData: [Data] = []
            let group = DispatchGroup()
            let historyRecordCount = [UInt8](data.resp)[40]
            for i in 0..<historyRecordCount {
                group.enter()
                tag.getTxn(index: UInt(i)) { (result) in
                    guard case .success(let data) = result else {
                        group.leave()
                        return
                    }
                    txnLogData.append(data.resp)
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                let detail = NFCCard(hexData: data.resp, txnLogHexData: txnLogData)
                completion(detail)
            }
        }
    }
    
    func getSecureData(_ tag: NFCISO7816Tag, completion: @escaping (NFCCardProtected) -> Void) {
        func generateTerminalRandom() -> String {
            return Array(0..<16).map { _ in
                return String(arc4random() % 16, radix: 16)
            }.joined()
        }
        
        func generateReadSecurePurseDataCommand(terminalRandom: String) -> String {
            let command = "903203000A1403" + terminalRandom + "71"
            return command
        }
        
        func removeStatusCode(_ hexStr: String) -> String {
            if hexStr.hasSuffix("9000") {
                return hexStr.substring(0, hexStr.count - 4)
            }
            return hexStr
        }
        
        func checkResponseStatus(_ purseData: Data) -> Bool {
            let hexStr = purseData.toHex().joined()
            return hexStr.hasSuffix("9000")
        }
        
        // CEPAS CARD Detail
        getChallenge(tag) { cardRandom in
            let terminalRandom = generateTerminalRandom()
            let readSecPurseCommand = generateReadSecurePurseDataCommand(terminalRandom: terminalRandom)
            sendCommand(tag, apdu: readSecPurseCommand) { result in
                guard case .success(let data) = result else {
                    print(NFCTapError.getSecPurseFailed)
                    return
                }
                let purseDataStr = removeStatusCode(data.resp.toHex().joined())
                guard purseDataStr.count >= 226 else {
                    print(NFCTapError.getSecPurseFailed)
                    return
                }
                let secure = NFCCardProtected(cardRandom: cardRandom, terminalRandom: purseDataStr, purseData: data.resp.toHex().joined())
                completion(secure)
                
            }
        }
    }
}
