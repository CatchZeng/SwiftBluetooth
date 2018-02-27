//
//  SBCentralManager.swift
//  SwiftBluetooth
//
//  Created by CatchZeng on 2017/7/27.
//  Copyright © 2017年 CatchZeng. All rights reserved.
//

import Foundation
import CoreBluetooth

open class SBCentralManager: NSObject, BluetoothCentral {
    // MARK: Public Property
    
    public typealias Element = BLEPeripheral

    public var isConnected: Bool {
        guard let first = connectedPeripherals.first,
        first.peripheral.state == .connected
         else { return false }
        return true
    }
    
    public var isConnecting: Bool {
        guard let connectOperation = connectOperation,
            case .running = connectOperation.state
            else {
                return false
        }
        return true
    }
    
    public var connectedPeripherals: [Element] {
        return peripheralContainer.connectedPeripherals
    }
    
    public var foundPeripherals: [Element] {
        return peripheralContainer.foundPeripherals
    }
    
    public var listeners = [SBCentraListenerWeakWrapper]()
    
    public var isBluetoothAvailable: Bool {
        return centralManager.state == .poweredOn
    }
    
    public var state: CenterState {
        return centralManager.centerState
    }
    
    public static var enableLog: Bool = false {
        didSet {
            SwiftBluetoothEnableLog = enableLog
        }
    }
    
    // MARK: Private Property
    
    fileprivate lazy var centralManager: CBCentralManager = {
        return CBCentralManager(delegate: self, queue: nil)
    }()
    
    fileprivate let peripheralContainer = BLEPeripheralContainer()
    
    fileprivate var scanOperation: ScanOperation?
    fileprivate var connectOperation: ConnectOperation?
    fileprivate var disconnectOperation: DisconnectOperation?

    // MARK: Shared
    
    public static let shared = SBCentralManager()
    
    private override init() {
    }
    
    // MARK: Public Methods

    @discardableResult
    public func start(listener: SBCentraListener? = nil) -> Self {
        // just for init centralManager
        _ = centralManager.state

        addListener(listener: listener)
        return self
    }

    public func addListener(listener: SBCentraListener?) {
        guard let listener = listener else {
            return
        }
        
        listeners = listeners.filter { $0.value != nil && $0.value !== listener }
        listeners.append(SBCentraListenerWeakWrapper(value: listener))
    }

    public func removeListener(listener: CentraListener?) {
        guard let listener = listener else {
            return
        }

        listeners = listeners.filter { $0.value != nil && $0.value !== listener }
    }

    // MARK: BluetoothCenter

    public func scan(serviceUUIDs: [CBUUID]?,
                     allowDuplicates: Bool,
                     filter: ((Element) -> (Bool))?,
                     sorter: ((Element, Element) -> (Bool))?,
                     callback: ((Result<(Element, [Element])>) -> Void)?) {
        if !isBluetoothAvailable {
            callback?(.failure(error: SwiftBluetoothError.bluetoothStateError))
            return
        }
        
        if scanOperation != nil {
            callback?(.failure(error: SwiftBluetoothError.multipleScan))
            return
        }
        
        scanOperation = ScanOperation(serviceUUIDs: serviceUUIDs,
                                      allowDuplicates: allowDuplicates,
                                      manager: centralManager,
                                      filter: filter,
                                      sorter: sorter,
                                      callback: {[weak self] (result) in
            switch result {
            case .success(let discoverPeripheral, let foundPeripheralList):
                guard let StrongSelf = self else {
                    return
                }
                
                if StrongSelf.peripheralContainer.hasFound(peripheral: discoverPeripheral) { // Update rssi
                    let rssi = NSNumber(value: discoverPeripheral.rssi)
                    StrongSelf.listeners.forEach {$0.value?.central(central: StrongSelf,
                                                                                    peripheral: discoverPeripheral,
                                                                                    didRSSIChanged: rssi)}
                    
                } else {
                    printLog("discovery: \(discoverPeripheral.name) count: \(foundPeripheralList.count)")
                }
                
                StrongSelf.peripheralContainer.foundPeripherals = foundPeripheralList
                
            default: break
            }
            
            callback?(result)
        })
        
        scanOperation?.start()
    }

    public func stopScan() {
        if !isBluetoothAvailable {
            return
        }
        
        scanOperation?.cancel()
        scanOperation = nil
    }

    public func connect(peripheral: Element,
                        timeoutInterval: TimeInterval,
                        callback: ((Result<Element>) -> Void)?) {
        if !isBluetoothAvailable {
            callback?(.failure(error: SwiftBluetoothError.bluetoothStateError))
            return
        }
        
        if let operation = connectOperation {
            if !operation.state.isFinished {
                callback?(.failure(error: SwiftBluetoothError.multipleConnect))
                printLog(SwiftBluetoothError.multipleConnect.errorDescription)
                return
            }
        }

        connectOperation = ConnectOperation(peripheral: peripheral,
                                         manager: centralManager,
                                         timeoutInterval: timeoutInterval,
                                         callback: callback)
        connectOperation?.start()
    }
    
    public func cancelConnecting() {
        connectOperation?.cancel()
    }

    public func disConnect(peripheral: Element, callback: ((Result<Element>) -> Void)?) {
        if !isBluetoothAvailable {
            callback?(.failure(error: SwiftBluetoothError.bluetoothStateError))
            return
        }
        
        disconnectOperation = DisconnectOperation(peripheral: peripheral,
                                                  manager: centralManager,
                                                  callback: callback)
        disconnectOperation?.start()
        
        listeners.forEach {$0.value?.central(central: self, onDisconnecting: peripheral)}
    }
}

// MARK: CBCentralManagerDelegate
extension SBCentralManager: CBCentralManagerDelegate {

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        printLog("central state: \(central.centerState.rawValue)")

        listeners.forEach {$0.value?.central(central: self, didChangeState: central.centerState)}
        listeners.forEach {$0.value?.central(central: self, available: central.state == .poweredOn)}
        
        if central.centerState == .poweredOff {
            peripheralContainer.powerOff()
            cancelConnecting()
        }
    }

    public func centralManager(_ central: CBCentralManager,
                               didDiscover peripheral: CBPeripheral,
                               advertisementData: [String: Any],
                               rssi RSSI: NSNumber) {
        scanOperation?.process(event: .didDiscoverPeripheral(peripheral, advertisementData, RSSI))
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let blePeripheral = peripheralContainer.addConnected(peripheral: peripheral) {
            blePeripheral.delegate = self
            connectOperation?.process(event: .didConnectPeripheral(blePeripheral))
            listeners.forEach {$0.value?.central(central: self, didConnect: blePeripheral)}
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectOperation?.fail(error)
        
        if error != nil {
            centralManager.cleanup(peripheral: peripheral)
        }
    }

    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        printLog("didDisconnectPeripheral")
        
        if let blePeripheral = peripheralContainer.connectedPeripheral(with: peripheral) {
            peripheralContainer.removeConnected(peripheral: blePeripheral)
            disconnectOperation?.process(event: .didDisconnectPeripheral(blePeripheral))
            listeners.forEach {$0.value?.central(central: self, didDisconnect: blePeripheral, error: error)}
        }
    }
}

// MARK: BLEPeripheralDelegate
extension SBCentralManager: BLEPeripheralDelegate {
    public func peripheral(_ peripheral: BLEPeripheral,
                    didReceive data: Data?,
                    on characteristic: CBCharacteristic) {
        if let data = data {
            listeners.forEach {$0.value?.central(central: self,
                                                device: peripheral,
                                                characteristic: characteristic,
                                                didReceive: .success(data))}
        }
    }

    public func peripheral(_ peripheral: BLEPeripheral, didRSSIChanged RSSI: NSNumber) {
        listeners.forEach {$0.value?.central(central: self,
                                            peripheral: peripheral,
                                            didRSSIChanged: RSSI)}
    }
    
    public func shouldCleanup(peripheral: CBPeripheral) {
        centralManager.cleanup(peripheral: peripheral)
    }
}
