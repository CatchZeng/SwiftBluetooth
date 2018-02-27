//
//  BLEPeripheralContainer.swift
//  SwiftBluetooth
//
//  Created by CatchZeng on 2017/12/22.
//

import Foundation
import CoreBluetooth

open class BLEPeripheralContainer: NSObject, PeripheralContainer {
    public typealias Element = BLEPeripheral
    
    public var connectedPeripherals: [Element] = []
    
    public var foundPeripherals: [Element] {
        set {
            mFoundPeripherals.removeAll()
            mFoundPeripherals.append(contentsOf: connectedPeripherals)
            mFoundPeripherals.append(contentsOf: newValue)
        }
        get {
            return mFoundPeripherals
        }
    }
    
    private var mFoundPeripherals: [Element] = []
    
    public override init() {
        super.init()
    }
    
    public func powerOff() {
        connectedPeripherals.removeAll()
        foundPeripherals.removeAll()
    }
    
    public func hasFound(peripheral: Element) -> Bool {
        if let _ = foundPeripheral(with: peripheral.peripheral) {
            return true
        }
        return false
    }
    
    public func addConnected(peripheral: CBPeripheral) -> Element? {
        guard let blePeripheral = foundPeripheral(with: peripheral) else {
            return nil
        }
        
        connectedPeripherals.append(blePeripheral)
        return blePeripheral
    }
    
    public func removeConnected(peripheral: Element) {
        guard let index = connectedPeripherals.index(of: peripheral) else {
            return
        }
        connectedPeripherals.remove(at: index)
    }
    
    public func connectedPeripheral(with peripheral: CBPeripheral) -> Element? {
        return connectedPeripherals.filter {$0.peripheral.identifier.uuidString == peripheral.identifier.uuidString}.first
    }
    
    private func foundPeripheral(with peripheral: CBPeripheral) -> Element? {
        return foundPeripherals.filter {$0.peripheral.identifier.uuidString == peripheral.identifier.uuidString}.first
    }
}
