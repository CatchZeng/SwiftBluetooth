//
//  Central.swift
//  SwiftBluetooth
//
//  Created by CatchZeng on 2017/7/27.
//  Copyright © 2017年 CatchZeng. All rights reserved.
//

import Foundation
import CoreBluetooth

public enum CenterState: String {
    case unknown
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
}

extension CBCentralManager {
    public var centerState: CenterState {
        switch state {
        case .poweredOff:
            return .poweredOff
        case .poweredOn:
            return .poweredOn
        case .resetting:
            return .resetting
        case .unauthorized:
            return .unauthorized
        case .unsupported:
            return .unsupported
        case .unknown:
            return .unknown
        }
    }
}

extension CBCentralManager {
    public func cleanup(peripheral: CBPeripheral) {
        printLog("clean up \(String(describing: peripheral.name))")
        
        cancelPeripheralConnection(peripheral)

        guard peripheral.state == .connected,
            let services = peripheral.services,
            services.count > 0 else {
                return
        }
        
        for service in services {
            guard let characteristics = service.characteristics,
                characteristics.count > 0 else {
                    continue
            }
            
            for characteristic in characteristics {
                if characteristic.isNotifying {
                    peripheral.setNotifyValue(false, for: characteristic)
                }
            }
        }
    }
}

public protocol Central {
    associatedtype Element: Peripheral
}

public protocol BluetoothCentral: Central {
    var isConnected: Bool { get }
    
    var connectedPeripherals: [Element]  { get }
    
    func scan(serviceUUIDs: [CBUUID]?,
              allowDuplicates: Bool,
              filter: ((Element) -> (Bool))?,
              sorter: ((Element, Element) -> (Bool))?,
              callback: ((Result<(Element, [Element])>) -> Void)?)

    func stopScan()

    func connect(peripheral: Element,
                 timeoutInterval: TimeInterval,
                 callback: ((Result<BLEPeripheral>) -> Void)?)

    func disConnect(peripheral: Element,
                    callback: ((Result<BLEPeripheral>) -> Void)?)
}

public protocol CentraListener: class {
    func central<C: Central>(central: C, didChangeState: CenterState)
    func central<C: Central>(central: C, didConnect device: Peripheral)
    func center<C: Central>(center: C, onConnecting device: Peripheral)
    func central<C: Central>(central: C, onDisconnecting device: Peripheral)
    func central<C: Central>(central: C, didDisconnect device: Peripheral, error: Error?)
}

extension CentraListener {
    public func central<C: Central>(central: C, didChangeState: CenterState) {}
    public func central<C: Central>(central: C, didConnect device: Peripheral) {}
    public func center<C: Central>(center: C, onConnecting device: Peripheral) {}
    public func central<C: Central>(central: C, onDisconnecting device: Peripheral) {}
    public func central<C: Central>(central: C, didDisconnect device: Peripheral, error: Error?) {}
}

public protocol SBCentraListener: CentraListener {
    func central<C: Central>(central: C,
                           available: Bool)
    
    func central<C: Central>(central: C,
                           device: BLEPeripheral,
                           characteristic: CBCharacteristic ,
                           didReceive data: Result<Data>)

    func central<C: Central>(central: C,
                           peripheral: BLEPeripheral,
                           didRSSIChanged RSSI: NSNumber)
}

extension SBCentraListener {
    public func central<C: Central>(central: C,
                           available: Bool) {}
    
    public func central<C: Central>(central: C,
                           device: BLEPeripheral,
                           characteristic: CBCharacteristic ,
                           didReceive data: Result<Data>) {}

    public func central<C: Central>(central: C,
                           peripheral: BLEPeripheral,
                           didRSSIChanged RSSI: NSNumber) {}
}

public struct CentralListenerWeakWrapper {
    weak var value: CentraListener?
}

public struct SBCentraListenerWeakWrapper {
    weak var value: SBCentraListener?
}
