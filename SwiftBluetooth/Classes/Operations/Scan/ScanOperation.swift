//
//  ScanOperation.swift
//  SwiftBluetooth
//
//  Created by CatchZeng on 2017/7/27.
//  Copyright © 2017年 CatchZeng. All rights reserved.
//

import Foundation
import CoreBluetooth

open class ScanOperation: BLEOperation {
    public typealias Element = BLEPeripheral
    private(set) var foundPeripheralList: [Element] = []
    
    private let serviceUUIDs: [CBUUID]?
    private let allowDuplicates: Bool
    private let filter: ((Element) -> (Bool))?
    private let sorter: ((Element, Element) -> (Bool))?
    private weak var manager: CBCentralManager?
    private var callback: ((Result<(Element, [Element])>) -> Void)?

    public init(serviceUUIDs: [CBUUID]? = nil,
         allowDuplicates: Bool = true,
         manager: CBCentralManager,
         filter: ((Element) -> (Bool))?,
         sorter: ((Element, Element) -> (Bool))?,
         callback: ((Result<(Element, [Element])>) -> Void)?) {

        self.serviceUUIDs = serviceUUIDs
        self.allowDuplicates = allowDuplicates
        self.manager = manager
        self.filter = filter
        self.sorter = sorter
        self.callback = callback
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: BLEOperation

    public override func start() {
        super.start()
        
        manager?.scanForPeripherals(withServices: serviceUUIDs,
                                    options: [CBCentralManagerScanOptionAllowDuplicatesKey: allowDuplicates])

        if allowDuplicates {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(didEnterBackgroundWithAllowDuplicates),
                name: NSNotification.Name.UIApplicationDidEnterBackground,
                object: nil
            )
        }
    }
    
    @discardableResult
    public override func process(event: Event) -> Any? {
        if case .didDiscoverPeripheral(let peripheral, _, let rssi) = event {
            let discoverPeripheral: Element = device(with: peripheral) ?? Element(peripheral: peripheral)
            discoverPeripheral.rssi = rssi.floatValue
            if addOrUpdateLegalPeripheral(peripheral: discoverPeripheral) {
                sortFoundList()
                
                super.success()
                callback?(.success((discoverPeripheral, foundPeripheralList)))
                
                return discoverPeripheral
            }
        }
        
        return nil
    }

    public override func cancel() {
        super.cancel()

        manager?.stopScan()

        callback?(.cancelled)
        callback = nil
    }

    public override func fail(_ error: Error?) {
        super.fail(error)

        callback?(.failure(error: error))
        callback = nil
    }

    // MARK: Private Methods
    
    private func device(with peripheral: CBPeripheral) -> Element? {
        return foundPeripheralList.filter {$0.peripheral == peripheral}.first
    }
    
    @discardableResult
    private func addOrUpdateLegalPeripheral(peripheral: Element) -> Bool {
        guard let filter = filter,
            filter(peripheral) else {
            return false
        }
        
        foundPeripheralList.update(use: peripheral)
        return true
    }

    private func sortFoundList() {
        if let sorter = sorter {
            foundPeripheralList = foundPeripheralList.sorted(by: sorter)
        }
    }

    @objc private func didEnterBackgroundWithAllowDuplicates() {
        fail(SwiftBluetoothError.allowDuplicatesInBackground)
    }
}
