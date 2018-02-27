//
//  BLEPeripheral.swift
//  SwiftBluetooth
//
//  Created by CatchZeng on 2017/7/27.
//  Copyright © 2017年 CatchZeng. All rights reserved.
//

import Foundation
import CoreBluetooth

public protocol BLEPeripheralDelegate: class {
    func peripheral(_ peripheral: BLEPeripheral, didReceive data: Data?, on characteristic: CBCharacteristic)
    func peripheral(_ peripheral: BLEPeripheral, didRSSIChanged RSSI: NSNumber)
    func shouldCleanup(peripheral: CBPeripheral)
}

public enum WriteWay {
    case directly
    case alternately(timeInterval: TimeInterval)
}

open class BLEPeripheral: NSObject, Peripheral, PeripheralUpdatable {
    //A value of <code>127</code> is reserved and indicates the RSSI was not available.
    public static let RSSIUnavailableValue: Float = 127
    
    public weak var delegate: BLEPeripheralDelegate?
    public var name = ""
    public var uuid = ""
    
    public var rssi: Float = RSSIUnavailableValue {
        didSet {
            delegate?.peripheral(self, didRSSIChanged: NSNumber(value: rssi))
        }
    }
    
    public var isRSSIUnavailable: Bool {
        return rssi == BLEPeripheral.RSSIUnavailableValue
    }

    public var peripheral: CBPeripheral!
    fileprivate var discoverServicesOperation: DiscoverServicesOperation?
    fileprivate var discoverCharacteristicsOperations = [CBUUID: DiscoverCharacteristicsOperation]()
    private lazy var buffer = WriteBuffer()
    private var curWriteOperation: WriteOperation?

    init(peripheral: CBPeripheral, rssi: Float? = nil) {
        super.init()
        self.peripheral = peripheral
        self.peripheral.delegate = self
        name = peripheral.name ?? ""
        uuid = peripheral.identifier.uuidString
        if let r = rssi {
            self.rssi = r
        }
    }

    public func discoverServices(serviceUUIDs: [CBUUID]?,
                                 callback: ((Result<[CBService]?>) -> Void)?) {
        // Cancel before.
        discoverServicesOperation?.cancel()
        
        discoverServicesOperation = DiscoverServicesOperation(peripheral: self,
                                                              serviceUUIDs: serviceUUIDs,
                                                              callback: callback)
        discoverServicesOperation?.start()
    }

    public func discoverCharacteristics(characteristicUUIDs: [CBUUID]?,
                                        service: CBService,
                                        callback: ((Result<[CBCharacteristic]?>) -> Void)?) {
        let discoverCharacteristicsOperation = DiscoverCharacteristicsOperation(peripheral: self,
                                                                   characteristicUUIDs: characteristicUUIDs,
                                                                   service: service,
                                                                   callback: callback)
        
        discoverCharacteristicsOperations[service.uuid] = discoverCharacteristicsOperation
        
        discoverCharacteristicsOperation.start()
    }
    
    public func writeValue(data: Data,
                           characteristic: CBCharacteristic,
                           type: CBCharacteristicWriteType,
                           way: WriteWay = .alternately(timeInterval: 0.01),
                           callback: ((Result<(Data)>) -> Void)? = nil) {
        let operation = WriteOperation(peripheral: self,
                                       data: data,
                                       characteristic: characteristic,
                                       type: type,
                                       callback: callback)
        
        curWriteOperation = operation
        
        switch way {
        case .directly:
            operation.start()
        case .alternately(let timeInterval):
            buffer.timeInterval = timeInterval
            buffer.add(operation: operation)
            break
        }
    }

    public func readRSSI() {
        peripheral.readRSSI()
    }
}

extension BLEPeripheral: CBPeripheralDelegate {

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            delegate?.shouldCleanup(peripheral: peripheral)

            discoverServicesOperation?.fail(error)
            return
        }
        
        discoverServicesOperation?.process(event: .didDiscoverServices)
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            delegate?.shouldCleanup(peripheral: peripheral)
            
            if let operation = discoverCharacteristicsOperations[service.uuid] {
                operation.fail(error)
                discoverCharacteristicsOperations.removeValue(forKey: service.uuid)
            }
            return
        }
        
        guard let operation = discoverCharacteristicsOperations[service.uuid] else {
            return
        }
        operation.process(event: .didDiscoverCharacteristics)
        
        discoverCharacteristicsOperations.removeValue(forKey: service.uuid)
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            printLog("didReceive: \(data.hexString)")
            delegate?.peripheral(self, didReceive: data, on: characteristic)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        self.rssi = RSSI.floatValue
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        curWriteOperation?.process(event: .didWriteCharacteristic(characteristic))
    }
}
