//
//  WatchDataSource.swift
//  Chess032WalletWatch Extension
//
//  Created by Marcos Rodriguez on 3/20/19.
//  Copyright © 2019 Facebook. All rights reserved.
//


import Foundation
import WatchConnectivity

class WatchDataSource: NSObject, WCSessionDelegate {
  struct NotificationName {
    static let dataUpdated = Notification.Name(rawValue: "Notification.WalletDataSource.Updated")
  }
  struct Notifications {
    static let dataUpdated = Notification(name: NotificationName.dataUpdated)
  }
  
  static let shared = WatchDataSource()
  var wallets: [Wallet] = [Wallet]()
  var companionWalletsInitialized = false
  private let keychain = KeychainSwift()
  
  override init() {
    super.init()
    if let existingData = keychain.getData(Wallet.identifier), let walletData = ((try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(existingData) as? [Wallet]) as [Wallet]??) {
      guard let walletData = walletData, walletData != self.wallets  else { return }
      wallets = walletData
      WatchDataSource.postDataUpdatedNotification()
    }
    if WCSession.isSupported() {
      print("Activating watch session")
      WCSession.default.delegate = self
      WCSession.default.activate()
    }
  }
  
  func processWalletsData(walletsInfo: [String: Any]) {
    if let walletsToProcess = walletsInfo["wallets"] as? [[String: Any]] {
      wallets.removeAll();
      for (index, entry) in walletsToProcess.enumerated() {
        guard let label = entry["label"] as? String, let balance = entry["balance"] as? String, let type = entry["type"] as? String, let preferredBalanceUnit = entry["preferredBalanceUnit"] as? String, let transactions = entry["transactions"] as? [[String: Any]]  else {
          continue
        }
        
        var transactionsProcessed = [Transaction]()
        for transactionEntry in transactions {
          guard let time = transactionEntry["time"] as? String, let memo = transactionEntry["memo"] as? String, let amount = transactionEntry["amount"] as? String, let type =  transactionEntry["type"] as? String else { continue }
          let transaction = Transaction(time: time, memo: memo, type: type, amount: amount)
          transactionsProcessed.append(transaction)
        }
        let receiveAddress = entry["receiveAddress"] as? String ?? ""
        let xpub = entry["xpub"] as? String ?? ""
        let hideBalance = entry["hideBalance"] as? Bool ?? false
        let wallet = Wallet(label: label, balance: balance, type: type, preferredBalanceUnit: preferredBalanceUnit, receiveAddress: receiveAddress, transactions: transactionsProcessed, identifier: index, xpub: xpub, hideBalance: hideBalance)
        wallets.append(wallet)
      }
      
      if let walletsArchived = try? NSKeyedArchiver.archivedData(withRootObject: wallets, requiringSecureCoding: false) {
        keychain.set(walletsArchived, forKey: Wallet.identifier)
      }
      WatchDataSource.postDataUpdatedNotification()
    }
  }
  
  static func postDataUpdatedNotification() {
    NotificationCenter.default.post(Notifications.dataUpdated)
  }
  
  static func requestLightningInvoice(walletIdentifier: Int, amount: Double, description: String?, responseHandler: @escaping (_ invoice: String) -> Void) {
    guard WatchDataSource.shared.wallets.count > walletIdentifier  else {
      responseHandler("")
      return
    }
    WCSession.default.sendMessage(["request": "createInvoice", "walletIndex": walletIdentifier, "amount": amount, "description": description ?? ""], replyHandler: { (reply: [String : Any]) in
      if let invoicePaymentRequest =  reply["invoicePaymentRequest"] as? String, !invoicePaymentRequest.isEmpty {
        responseHandler(invoicePaymentRequest)
      } else {
        responseHandler("")
      }
    }) { (error) in
      print(error)
      responseHandler("")
      
    }
  }
  
  static func toggleWalletHideBalance(walletIdentifier: Int, hideBalance: Bool, responseHandler: @escaping (_ invoice: String) -> Void) {
    guard WatchDataSource.shared.wallets.count > walletIdentifier  else {
      responseHandler("")
      return
    }
    WCSession.default.sendMessage(["message": "hideBalance", "walletIndex": walletIdentifier, "hideBalance": hideBalance], replyHandler: { (reply: [String : Any]) in
        responseHandler("")
    }) { (error) in
      print(error)
      responseHandler("")
      
    }
  }
  
  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    processData(data: applicationContext)
  }
  
  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
    processData(data: applicationContext)
  }
  
  func processData(data: [String: Any]) {
    if let preferredFiatCurrency = data["preferredFiatCurrency"] as? String, let  preferredFiatCurrencyUnit = fiatUnit(currency: preferredFiatCurrency) {
      UserDefaults.standard.set(preferredFiatCurrencyUnit.endPointKey, forKey: "preferredFiatCurrency")
      UserDefaults.standard.synchronize()
        ExtensionDelegate.preferredFiatCurrencyChanged()
    } else if let isWalletsInitialized = data["isWalletsInitialized"] as? Bool {
      companionWalletsInitialized = isWalletsInitialized
      NotificationCenter.default.post(Notifications.dataUpdated)
    } else {
      WatchDataSource.shared.processWalletsData(walletsInfo: data)
    }
  }
  
  func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
    processData(data: userInfo)
  }
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    if activationState == .activated {
      WCSession.default.sendMessage(["message" : "sendApplicationContext"], replyHandler: { (replyData) in
      }) { (error) in
        print(error)
      }
    } else {
      WatchDataSource.shared.companionWalletsInitialized = false
    }
  }
  
}
