//
//  SBCentraListener.swift
//  Pods-SwiftBluetooth_Example
//
//  Created by CatchZeng on 2018/7/30.
//

import Foundation
import CoreBluetooth

public protocol SBCentraListener: class {
    func central(_ central: SBCentralManager, didChangeState: CenterState)
    
    func central(_ central: SBCentralManager, didConnect device: Peripheral)
    
    func central(_ central: SBCentralManager, onConnecting device: Peripheral)
    
    func central(_ central: SBCentralManager, onDisconnecting device: Peripheral)
    
    func central(_ central: SBCentralManager, didDisconnect device: Peripheral, error: Error?)
    
    func central(_ central: SBCentralManager, available: Bool)
    
    func central(_ central: SBCentralManager,
                 device: BLEPeripheral,
                 characteristic: CBCharacteristic ,
                 didReceive data: Result<Data>)
    
    func central(_ central: SBCentralManager,
                 peripheral: BLEPeripheral,
                 didRSSIChanged RSSI: NSNumber)
}

extension SBCentraListener {
    public func central(_ central: SBCentralManager, didChangeState: CenterState) {}
    
    public func central(_ central: SBCentralManager, didConnect device: Peripheral) {}
    
    public func central(_ central: SBCentralManager, onConnecting device: Peripheral) {}
    
    public func central(_ central: SBCentralManager, onDisconnecting device: Peripheral) {}
    
    public func central(_ central: SBCentralManager, didDisconnect device: Peripheral, error: Error?) {}
    
    public func central(_ central: SBCentralManager, available: Bool) {}
    
    public func central(_ central: SBCentralManager,
                        device: BLEPeripheral,
                        characteristic: CBCharacteristic ,
                        didReceive data: Result<Data>) {}
    
    public func central(_ central: SBCentralManager,
                        peripheral: BLEPeripheral,
                        didRSSIChanged RSSI: NSNumber) {}
}

public struct SBCentraListenerWeakWrapper {
    weak var value: SBCentraListener?
}
