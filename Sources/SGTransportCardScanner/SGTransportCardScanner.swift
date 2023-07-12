//
//  Scanner.swift
//  MrtCardScanner
//
//  Created by Aung Ko Min on 12/7/23.
//

import Foundation
import CoreNFC

public enum ExpressCardTapStepMapping: Float {
    case tagConnected = 1
    case getChallengeSuccess = 2
    case getCardInfoSuccess = 3
}


public class SGTransportCardScanner: NSObject {
    
    private var nfcCardDetected: ((NFCCard) -> Void)?
    private var onShowAlertMessage: ((String, String) -> Void)?
    
    public override init( ) {
        super.init()
    }
    
    public func setNfcCardDetectedBlock(_ nfcCardDetected: @escaping ((NFCCard) -> Void)) {
        self.nfcCardDetected = nfcCardDetected
    }
    
    public func setOnShowAlertMessage(_ onShowAlertMessage: @escaping ((String, String) -> Void)) {
        self.onShowAlertMessage = onShowAlertMessage
    }
    
    public func beginScan() {
        let pollingOption = NFCTagReaderSession.PollingOption(arrayLiteral: .iso14443)
        guard NFCNDEFReaderSession.readingAvailable,
              let tagSession = NFCTagReaderSession(pollingOption: pollingOption, delegate: self) else {
            self.displayNFCNotSupportAlert()
            return
        }
        tagSession.alertMessage = "Please tap and hold your MRT Card at the NFC scanning area. Do not remove until it reaches 100%."
        tagSession.begin()
    }
    
    private func displayNFCNotSupportAlert() {
        onShowAlertMessage?("Scanning Not Supported", "This device doesn't support tag scanning.")
    }
}

extension SGTransportCardScanner: NFCCommandSending, NFCTagReaderSessionDelegate {
    
    public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        
    }
    
    public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        session.invalidate(errorMessage: error.localizedDescription)
    }
    
    public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let unconnectedTag = tags.first, case .iso7816(let tag) = unconnectedTag else {
            session.invalidate(errorMessage: "You have experienced a timeout, please try again.")
            return
        }
        session.connect(to: unconnectedTag) { [weak self] (error) in
            guard let self = self else { return }
            if let error = error {
                session.invalidate(errorMessage: error.localizedDescription)
                return
            }
            
            session.alertMessage = self.processDesc(step: .tagConnected)
            
            getChallenge(tag) { challenge in
                session.alertMessage = self.processDesc(step: .getChallengeSuccess)
                self.getCardDetailWithTxnRecord(tag) { details in
                    session.alertMessage = self.processDesc(step: .getCardInfoSuccess)
                    session.invalidate()
                    DispatchQueue.main.async {
                        self.nfcCardDetected?(details)
                    }
                }
            }
        }
    }

    func processDesc(step: ExpressCardTapStepMapping) -> String {
        let stepInPercentage: String = {
            let totalStep: Float = 3
            if case .getCardInfoSuccess = step {
                return "100"
            } else {
                return String(format: "%.0f", step.rawValue / totalStep * 100 + Float.random(in: 0..<8))
            }
        }()
        return "Scanning: \(stepInPercentage)%...Tap and hold your MRT Card at the NFC scanning area. Do not remove until it reaches 100%."
    }
}
