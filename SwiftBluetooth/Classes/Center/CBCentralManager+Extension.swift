//
//  CBCentralManager+Extension.swift
//  Pods-SwiftBluetooth_Example
//
//  Created by CatchZeng on 2018/7/30.
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
