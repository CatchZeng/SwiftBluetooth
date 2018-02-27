//
//  Peripheral.swift
//  SwiftBluetooth
//
//  Created by CatchZeng on 2017/7/27.
//  Copyright © 2017年 CatchZeng. All rights reserved.
//

import Foundation

public protocol Peripheral {
    var name: String {get set}
    var uuid: String {get set}
    var rssi: Float {get set}
    var primaryKey: String {get}
}

extension Peripheral {
    public var primaryKey: String {
        return uuid
    }
}

public protocol PeripheralUpdatable {
    mutating func update(use element: Peripheral)
}

extension PeripheralUpdatable where Self: Peripheral {
    mutating public func update(use peripheral: Peripheral) {
        uuid = peripheral.uuid
        name = peripheral.name
        rssi = peripheral.rssi
    }
}

public protocol PeripheralContainer: class {
    associatedtype Element: Peripheral
    var connectedPeripheral: Element? {get}
    var connectedPeripherals: [Element] {get set}
    var foundPeripherals: [Element] {get set}
}

extension PeripheralContainer {
    public var connectedPeripheral: Element? {
        return connectedPeripherals.first
    }
}

extension Array where Element: Peripheral, Element: Equatable, Element: PeripheralUpdatable {
    mutating func update(use element: Element) {
        if let existIndex = index(of: element) {
            var existPeripheral = self[existIndex]
            existPeripheral.update(use: element)
        } else {
            append(element)
        }
    }
}
