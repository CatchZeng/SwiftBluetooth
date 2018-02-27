//
//  DisconnectOperation.swift
//  SwiftBluetooth
//
//  Created by CatchZeng on 2017/7/31.
//  Copyright © 2017年 CatchZeng. All rights reserved.
//

import Foundation
import CoreBluetooth

open class DisconnectOperation: BLEOperation {
    private weak var manager: CBCentralManager?
    private var peripheral: BLEPeripheral
    private var callback: ((Result<BLEPeripheral>) -> Void)?

    public init(peripheral: BLEPeripheral, manager: CBCentralManager, callback: ((Result<BLEPeripheral>) -> Void)?) {
        self.peripheral = peripheral
        self.manager = manager
        self.callback = callback
    }
    
    // MARK: BLEOperation
    
    public override func start() {
        super.start()
        manager?.cleanup(peripheral: peripheral.peripheral)
        printLog("Start disconnecting from \(peripheral.name).")
    }
    
    @discardableResult
    public override func process(event: Event) -> Any? {
        if case .didDisconnectPeripheral(let peripheral) = event {
            success(peripheral)
            return peripheral
        }
        return nil
    }

    public override func cancel() {
        super.cancel()
        printLog("cancel disconnect \(peripheral.name).")
        callback?(.cancelled)
        callback = nil
    }

    public override func fail(_ error: Error?) {
        super.fail(error)
        printLog("fail disconnect \(peripheral.name).")
        callback?(.failure(error: error))
        callback = nil
    }

    // MARK: Private Methods
    
    private func success(_ peripheral: BLEPeripheral) {
        super.success()
        printLog("did disconnect \(peripheral.name).")
        callback?(.success(peripheral))
        callback = nil
    }
}
