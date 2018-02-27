//
//  DiscoverCharacteristicsOperation.swift
//  SwiftBluetooth
//
//  Created by CatchZeng on 2017/9/5.
//  Copyright © 2017年 CatchZeng. All rights reserved.
//

import UIKit
import CoreBluetooth

open class DiscoverCharacteristicsOperation: BLEOperation {
    var peripheral: BLEPeripheral
    var service: CBService
    var characteristicUUIDs: [CBUUID]?
    private var callback: ((Result<[CBCharacteristic]?>) -> Void)?

    public init(peripheral: BLEPeripheral, characteristicUUIDs: [CBUUID]?, service: CBService, callback: ((Result<[CBCharacteristic]?>) -> Void)?) {
        self.peripheral = peripheral
        self.service = service
        self.characteristicUUIDs = characteristicUUIDs
        self.callback = callback
    }

    // MARK: BLEOperation

    public override func start() {
        if peripheral.peripheral.state != .connected {
            fail(SwiftBluetoothError.bluetoothStateError)
            return
        }
        
        super.start()
        
        peripheral.peripheral.discoverCharacteristics(characteristicUUIDs, for: service)
    }

    @discardableResult
    public override func process(event: Event) -> Any? {
        if case .didDiscoverCharacteristics = event {
            success()
            return service.characteristics
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

        callback?(.success(service.characteristics))
        callback = nil
    }
}
