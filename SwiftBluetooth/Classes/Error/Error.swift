//
//  Error.swift
//  SwiftBluetooth
//
//  Created by CatchZeng on 2017/7/27.
//  Copyright © 2017年 CatchZeng. All rights reserved.
//

import Foundation

public enum SwiftBluetoothError: Int {
    case allowDuplicatesInBackground
    case connectionTimedOut
    case bluetoothStateError
    case multipleScan
    case multipleConnect
}

extension SwiftBluetoothError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .allowDuplicatesInBackground:
            return "Scanning with allow duplicates while in the background is not supported."
        case .connectionTimedOut:
            return "Connection timed out."
        case .bluetoothStateError:
            return "Bluetooth state error."
        case .multipleScan:
            return "Multiple scan is not supported. You need stop scan before start scan."
        case .multipleConnect:
            return "Multiple connect is not supported. You need cancel current connect operation."
        }
    }
}

extension SwiftBluetoothError: CustomNSError {
    public static var errorDomain: String {
        return "SwiftBluetooth"
    }
    
    public var errorCode: Int {
        switch self {
        case .allowDuplicatesInBackground: return 1
        case .connectionTimedOut: return 2
        case .bluetoothStateError: return 3
        case .multipleScan: return 4
        case .multipleConnect: return 5
        }
    }
    
    public var errorUserInfo: [String : Any] {
        guard let errorDescription = errorDescription else {
            return [:]
        }
        
        return [
            NSLocalizedDescriptionKey: errorDescription
        ]
    }
}
