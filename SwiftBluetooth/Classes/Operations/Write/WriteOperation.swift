//
//  WriteOperation.swift
//  SwiftBluetooth
//
//  Created by CatchZeng on 2017/9/5.
//  Copyright © 2017年 CatchZeng. All rights reserved.
//

import UIKit
import CoreBluetooth

open class WriteOperation: BLEOperation {
    // Maximum 20 bytes in a single ble package
    private static let notifyMTU = 20

    private var peripheral: BLEPeripheral
    private var data: Data
    private var characteristic: CBCharacteristic
    private var type: CBCharacteristicWriteType
    private var callback: ((Result<(Data)>) -> Void)?

    public init(peripheral: BLEPeripheral, data: Data, characteristic: CBCharacteristic, type: CBCharacteristicWriteType, callback: ((Result<(Data)>) -> Void)?) {
        self.peripheral = peripheral
        self.data = data
        self.characteristic = characteristic
        self.type = type
        self.callback = callback
    }

    // MARK: BLEOperation
    
    public override func start() {
        if peripheral.peripheral.state != .connected {
            printLog("bluetooth is disconnected.")
            return
        }
        super.start()
        writeValue()
        
        if type == .withoutResponse {
            success()
        }
    }
    
    @discardableResult
    public override func process(event: Event) -> Any? {
        if type == .withoutResponse {
            return nil
        }
        
        if case .didWriteCharacteristic(let characteristic) = event {
            if characteristic.uuid == self.characteristic.uuid {
                success()
            }
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
        
        callback?(.success(data))
        callback = nil
    }
    
    // MARK: Private Methods

    private func writeValue() {
        var sendIndex = 0
        while true {
            var amountToSend = data.count - sendIndex
            if amountToSend > WriteOperation.notifyMTU {
                amountToSend = WriteOperation.notifyMTU
            }
            if amountToSend <= 0 {
                return
            }
            let dataChunk = data.subdata(in: sendIndex..<sendIndex+amountToSend)
            printLog("didSend: \(dataChunk.hexString)")
            peripheral.peripheral.writeValue(dataChunk, for: characteristic, type: type)
            sendIndex += amountToSend
        }
    }
}
