//
//  Result.swift
//  SwiftBluetooth
//
//  Created by CatchZeng on 2017/7/27.
//  Copyright © 2017年 CatchZeng. All rights reserved.
//

import Foundation

public enum Result<T> {
    case success(T)
    case cancelled
    case failure(error: Error?)
}
