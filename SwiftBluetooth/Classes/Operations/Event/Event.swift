//
//  Event.swift
//  SwiftBluetooth
//
//  Created by CatchZeng on 2017/7/27.
//  Copyright © 2017年 CatchZeng. All rights reserved.
//

import Foundation
import CoreBluetooth

public enum Event {
    case didDiscoverServices
    case didDiscoverCharacteristics
    case didDiscoverPeripheral(CBPeripheral, [String: Any], NSNumber)
    case didConnectPeripheral(BLEPeripheral)
    case didDisconnectPeripheral(BLEPeripheral)
    case didReadCharacteristic(CBCharacteristic, Data)
    case didWriteCharacteristic(CBCharacteristic)
    case didUpdateCharacteristicNotificationState(CBCharacteristic)
}
