//
//  InterfaceController.swift
//  Chess032WalletWatch Extension
//
//  Created by Marcos Rodriguez on 3/6/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

import WatchKit
import WatchConnectivity
import Foundation

class InterfaceController: WKInterfaceController {
  
  @IBOutlet weak var walletsTable: WKInterfaceTable!
  @IBOutlet weak var loadingIndicatorGroup: WKInterfaceGroup!
  @IBOutlet weak var noWalletsAvailableLabel: WKInterfaceLabel!
  
  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
    
    if (WatchDataSource.shared.wallets.isEmpty) {
      loadingIndicatorGroup.setHidden(true)
      noWalletsAvailableLabel.setHidden(false)
    } else {
      processWalletsTable()
    }
    NotificationCenter.default.addObserver(self, selector: #selector(processWalletsTable), name: WatchDataSource.NotificationName.dataUpdated, object: nil)
  }
  
  @objc private func processWalletsTable() {
    walletsTable.setNumberOfRows(WatchDataSource.shared.wallets.count, withRowType: WalletInformation.identifier)
    
    for index in 0..<walletsTable.numberOfRows {
      guard let controller = walletsTable.rowController(at: index) as? WalletInformation else { continue }
      let wallet = WatchDataSource.shared.wallets[index]
      if wallet.identifier == nil {
        WatchDataSource.shared.wallets[index].identifier = index
      }
      controller.walletBalanceLabel.setHidden(wallet.hideBalance)
      controller.name = wallet.label
      controller.balance = wallet.hideBalance ? "" : wallet.balance
      controller.type = WalletGradient(rawValue: wallet.type) ?? .SegwitHD
    }
    noWalletsAvailableLabel.setHidden(!WatchDataSource.shared.wallets.isEmpty)
    walletsTable.setHidden(WatchDataSource.shared.wallets.isEmpty)
  }
  
  override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
    return rowIndex;
  }
  
}
