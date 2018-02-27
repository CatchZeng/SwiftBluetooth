# SwiftBluetooth
A simple framework for building BLE apps.

[![CI Status](http://img.shields.io/travis/CatchZeng/SwiftBluetooth.svg?style=flat)](https://travis-ci.org/CatchZeng/SwiftBluetooth)
[![Version](https://img.shields.io/cocoapods/v/SwiftBluetooth.svg?style=flat)](http://cocoapods.org/pods/SwiftBluetooth)
[![License](https://img.shields.io/cocoapods/l/SwiftBluetooth.svg?style=flat)](http://cocoapods.org/pods/SwiftBluetooth)
[![Platform](https://img.shields.io/cocoapods/p/SwiftBluetooth.svg?style=flat)](http://cocoapods.org/pods/SwiftBluetooth)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage

### Central

#### Init SBCentralManager

```swift
let central = SBCentralManager()
//or
let central = SBCentralManager.shared
```
#### Start with listener or not

```swift
central.start(listener: self)
//or
central.start()
```

#### Properties

```swift
state
isConnected
isConnecting
connectedPeripherals
foundPeripherals
isBluetoothAvailable
......
```

#### Implement SBCenterListener

```swift
func central<C>(central: C, available: Bool) where C : Central {
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

```

#### Log config

```swift
SBCentralManager.enableLog = true
```

#### Scan

```swift
// !!! Scan will fail beofre bluetooth available.

central.scan(serviceUUIDs: nil,
                             allowDuplicates: false,
                             filter: { (peripheral) -> (Bool) in
                             // You can filter peripheral by name or other properties.
                             // return peripheral.name.contains("your custom bluetooth name.")
                             return true
}, sorter: { (peripheral1, peripheral2) -> (Bool) in
    // You can sort peripheral by rssi or other properties.
    return peripheral1.rssi < peripheral2.rssi
}) { (result) in
    switch result {
    case .success(let discoverPeripheral, let foundPeripheralList):
    break
    case .cancelled:
    print("Scan cancelled.")
    case .failure(let error):
    print("Scan error: \(error?.localizedDescription ?? "")")
    }
}

central.stopScan()
```

#### Connection

```swift
central.connect(peripheral: discoverPeripheral,
                timeoutInterval: 10,
                callback: { (result) in
                switch result {
                case .success(let peripheral):
                    print("Connect periphera:\(peripheral.name).")
                case .cancelled:
                    print("Connect cancelled.")
                case .failure(let error):
                    print("Connect error: \(error?.localizedDescription ?? "")")
                }
})


central.cancelConnecting()


central.disConnect(element: peripheral) { (result) in
                switch result {
                case .success(let peripheral):
                    print("Disconnect periphera:\(peripheral.name).")
                case .cancelled:
                    print("Disconnect cancelled.")
                case .failure(let error):
                    print("Disconnect error: \(error?.localizedDescription ?? "")")
                }
}

```

### Peripheral

#### Properties

```swift
name
uuid
rssi
......
```
#### Service

```swift
peripheral.discoverServices(serviceUUIDs: nil, callback: { (result) in
    switch result {
    case .success(let services):
        print("DiscoverServices:\(services).")
    case .cancelled:
        print("DiscoverServices cancelled.")
    case .failure(let error):
        print("DiscoverServices error: \(error?.localizedDescription ?? "")")
    }
})
```

#### Characteristic

```swift
peripheral.discoverCharacteristics(characteristicUUIDs: nil, service: service) { (result) in
    switch result {
    case .success(let characteristics):
        print("DiscoverCharacteristics:\(String(describing: characteristics?.count)).")
    case .cancelled:
        print("Characteristics cancelled.")
    case .failure(let error):
        print("Characteristics error: \(error?.localizedDescription ?? "")")
    }
}
```

#### WriteValue

```swift
peripheral.writeValue(data: data,
                      characteristic: characteristic,
                      type: .withResponse)
```


#### ReadRSSI

```swift
peripheral.readRSSI()
```

## Installation

SwiftBluetooth is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SwiftBluetooth'
```

## Author

CatchZeng, 891793848@qq.com

## License

SwiftBluetooth is available under the MIT license. See the LICENSE file for more info.
