//
//  DiscoverServicesOperation.swift
//  SwiftBluetooth
//
//  Created by CatchZeng on 2017/8/31.
//  Copyright © 2017年 CatchZeng. All rights reserved.
//

import UIKit
import CoreBluetooth

open class DiscoverServicesOperation: BLEOperation {
    var peripheral: BLEPeripheral
    var serviceUUIDs: [CBUUID]?
    private var callback: ((Result<[CBService]?>) -> Void)?

    public init(peripheral: BLEPeripheral, serviceUUIDs: [CBUUID]?, callback: ((Result<[CBService]?>) -> Void)?) {
        self.peripheral = peripheral
        self.serviceUUIDs = serviceUUIDs
        self.callback = callback
    }

    // MARK: BLEOperation

    public override func start() {
        if peripheral.peripheral.state != .connected {
            fail(SwiftBluetoothError.bluetoothStateError)
            return
        }

        super.start()
        peripheral.peripheral.discoverServices(serviceUUIDs)
    }

    @discardableResult
    public override func process(event: Event) -> Any? {
        if case .didDiscoverServices = event {
            success()
            return peripheral.peripheral.services
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

        callback?(.failure(error: error))
        callback = nil
    }
    
    public override func success() {
        super.success()

        callback?(.success(peripheral.peripheral.services))
        callback = nil
    }
}
