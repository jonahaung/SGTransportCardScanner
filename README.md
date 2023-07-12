# SGTransportCardScanner

NFC Transport Card Reader framework for Singapore Transport Cards
# Installation
add Swift package at "https://github.com/jonahaung/SGTransportCardScanner"
# Usage

    import SwiftUI
    import SGTransportCardScanner
    public class NFCScanner: ObservableObject {
        @Published var cardDetail: NFCCard?
        private let interactor = SGTransportCardScanner()
        public init() {
            interactor.setNfcCardDetectedBlock { [weak self] card in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.cardDetail = card
                }
            }
        }
        public func beginScan() {
            interactor.beginScan()
        }
    }

    <img src="relative/path/in/repository/to/IMG_4090.png" width="128"/>
