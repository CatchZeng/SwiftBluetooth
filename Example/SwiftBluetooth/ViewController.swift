//
//  ViewController.swift
//  SwiftBluetooth
//
//  Created by CatchZeng on 12/12/2017.
//  Copyright (c) 2017 CatchZeng. All rights reserved.
//

import UIKit
import SwiftBluetooth
import CoreBluetooth

class ViewController: UIViewController, SBCentraListener {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SBCentralManager.shared.start(listener: self)
        SBCentralManager.enableLog = true
        
        // Scan will fail beofre bluetooth available.
        scan()
        
        
        //SBCentralManager.shared.stopScan()
    }

    func central<C>(central: C, available: Bool) where C : Central {
        if available {
            scan()
        }
    }
    
    func central<C>(central: C, didChangeState: CenterState) where C : Central {
    }
    
    func central<C>(central: C, didConnect device: Peripheral) where C : Central {
        
    }
    
    func central<C>(central: C, onDisconnecting device: Peripheral) where C : Central {
    }
    
    func central<C>(central: C, didDisconnect device: Peripheral, error: Error?) where C : Central {
    }
    
    func central<C>(central: C, peripheral: BLEPeripheral, didRSSIChanged RSSI: NSNumber) where C : Central {
    }
    
    func central<C>(central: C, device: BLEPeripheral, characteristic: CBCharacteristic, didReceive data: Result<Data>) where C : Central {
    }
    
    fileprivate func disconnect(_ peripheral: (SBCentralManager.Element)) {
        SBCentralManager.shared.disConnect(peripheral: peripheral) { (result) in
            switch result {
            case .success(let peripheral):
                print("Disconnect periphera:\(peripheral.name).")
            case .cancelled:
                print("Disconnect cancelled.")
            case .failure(let error):
                print("Disconnect error: \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    fileprivate func discoverCharacteristics(_ peripheral: (SBCentralManager.Element), _ service: CBService) {
        peripheral.discoverCharacteristics(characteristicUUIDs: nil, service: service) { (result) in
            switch result {
            case .success(let characteristics):
                print("DiscoverCharacteristics:\(String(describing: characteristics?.count)).")
                
                if let characteristic = characteristics?.first {
                    peripheral.writeValue(data: Data(), characteristic: characteristic, type: .withResponse)
                }
                
            case .cancelled:
                print("Characteristics cancelled.")
            case .failure(let error):
                print("Characteristics error: \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    fileprivate func discoverServices(_ peripheral: (SBCentralManager.Element)) {
        peripheral.discoverServices(serviceUUIDs: nil, callback: {[weak self] (result) in
            switch result {
            case .success(let services):
                print("DiscoverServices:\(String(describing: services?.count)).")
                
                if let service = services?.first {
                    self?.discoverCharacteristics(peripheral, service)
                }
            case .cancelled:
                print("DiscoverServices cancelled.")
            case .failure(let error):
                print("DiscoverServices error: \(error?.localizedDescription ?? "")")
            }
        })
    }
    
    fileprivate func connect(_ discoverPeripheral: SBCentralManager.Element) {
        SBCentralManager.shared.connect(peripheral: discoverPeripheral,
                                        timeoutInterval: 10,
                                        callback: {[weak self] (result) in
                                            switch result {
                                            case .success(let peripheral):
                                                print("Connect periphera:\(peripheral.name).")
                                                
                                                self?.discoverServices(peripheral)
                                                
                                            case .cancelled:
                                                print("Connect cancelled.")
                                            case .failure(let error):
                                                print("Connect error: \(error?.localizedDescription ?? "")")
                                            }
        })
    }
    
    fileprivate func scan() {
        // Scan will fail beofre bluetooth available.
        SBCentralManager.shared.scan(serviceUUIDs: nil,
                                     allowDuplicates: false,
                                     filter: { (peripheral) -> (Bool) in
                                        // You can filter peripheral by name or other properties.
                                        // return peripheral.name.contains("your custom bluetooth name.")
                                        return true
        }, sorter: { (peripheral1, peripheral2) -> (Bool) in
            // You can sort peripheral by rssi or other properties.
            return peripheral1.rssi < peripheral2.rssi
        }) {[weak self] (result) in
            switch result {
            case .success(let discoverPeripheral, _ ):
                self?.connect(discoverPeripheral)
                break
            case .cancelled:
                print("Scan cancelled.")
            case .failure(let error):
                print("Scan error: \(error?.localizedDescription ?? "")")
            }
        }
    }
}

