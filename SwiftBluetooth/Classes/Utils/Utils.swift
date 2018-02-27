//
//  Utils.swift
//  SwiftBluetooth
//
//  Created by CatchZeng on 2017/7/27.
//  Copyright © 2017年 CatchZeng. All rights reserved.
//

import Foundation

public var SwiftBluetoothEnableLog = false

func printLog<T>(_ message: T, file: String = #file, line: Int = #line) {
    if SwiftBluetoothEnableLog {
        let fileName = (file as NSString).lastPathComponent.replacingOccurrences(of: ".swift", with: "")
        
        let dformatter = DateFormatter()
        dformatter.dateFormat = "mm:ss:SSS"
        let datestr = dformatter.string(from: Date())
        
        print("\(datestr)[SwiftBluetooth]\(fileName)[\(line)]: \(message)")
    }
}
