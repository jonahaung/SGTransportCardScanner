# SGTransportCardScanner
<p align="left">
  <img src="https://github.com/jonahaung/SGTransportCardScanner/blob/main/IMG_4091.png" width="250"/>
  <img src="https://github.com/jonahaung/SGTransportCardScanner/blob/main/IMG_4090.png" width="250"/>
</p>

NFC Transport Card Reader framework for Singapore Transport Cards

# Installation
Add Swift package at "https://github.com/jonahaung/SGTransportCardScanner"

# Usage Example
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
