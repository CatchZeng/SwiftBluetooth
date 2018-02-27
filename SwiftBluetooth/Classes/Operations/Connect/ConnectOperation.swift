//
//  ConnectOperation.swift
//  SwiftBluetooth
//
//  Created by CatchZeng on 2017/7/28.
//  Copyright © 2017年 CatchZeng. All rights reserved.
//

import Foundation
import CoreBluetooth

var standardConnectOptions: [String: AnyObject] = [
    CBConnectPeripheralOptionNotifyOnDisconnectionKey: true as AnyObject,
    CBConnectPeripheralOptionNotifyOnConnectionKey: true as AnyObject
]

open class ConnectOperation: BLEOperation {
    private weak var manager: CBCentralManager?
    private var peripheral: BLEPeripheral
    private var callback: ((Result<BLEPeripheral>) -> Void)?
    private var connectionTimer: Timer?
    private var timeoutInterval: TimeInterval = 15

    public init(peripheral: BLEPeripheral, manager: CBCentralManager, timeoutInterval: TimeInterval, callback: ((Result<BLEPeripheral>) -> Void)?) {
        self.manager = manager
        self.peripheral = peripheral
        self.timeoutInterval = timeoutInterval
        self.callback = callback
    }

    // MARK: : BLEOperation

    public override func start() {
        super.start()
        
        manager?.connect(peripheral.peripheral, options: standardConnectOptions)

        cancelTimer()

        if #available(iOS 10.0, *) {
            connectionTimer = Timer.scheduledTimer(withTimeInterval: timeoutInterval, repeats: false, block: { (_) in
                self.timedOut()
            })
        } else {
            connectionTimer = Timer.scheduledTimer(
                timeInterval: timeoutInterval,
                target: self,
                selector: #selector(timedOut),
                userInfo: nil,
                repeats: false
            )
        }
    }

    @discardableResult
    public override func process(event: Event) -> Any? {
        if case .didConnectPeripheral(let peripheral) = event {
            success(peripheral)
            return peripheral
        }
        return nil
    }

    public override func cancel() {
        super.cancel()

        callback?(.cancelled)
        callback = nil
    }

    public override func fail(_ error: Error?) {
        super.fail(error)
        
        printLog("Failed connecting to: \(peripheral.name) with error: \(String(describing: error?.localizedDescription))")
        
        callback?(.failure(error: error))
        callback = nil
    }

    // MARK: Private Methods

    private func success(_ peripheral: BLEPeripheral) {
        super.success()
        
        printLog("Connected to: \(peripheral.name).")

        cancelTimer()
        callback?(.success(peripheral))
        callback = nil
    }

    private func cancelTimer() {
        connectionTimer?.invalidate()
        connectionTimer = nil
    }

    @objc private func timedOut() {
        fail(SwiftBluetoothError.connectionTimedOut)
    }
}
