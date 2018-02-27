//
//  BytesKit.swift
//  SwiftBluetooth
//
//  Created by CatchZeng on 2017/7/27.
//  Copyright © 2017年 CatchZeng. All rights reserved.
//

import Foundation

public protocol BytesConvertible {
    var bytes: [UInt8] { get }
}

extension Int: BytesConvertible {
    public var bytes: [UInt8] {
        var value = self
        var bytesArray: [UInt8] = [0, 0, 0, 0]
        var i = 4
        repeat {
            i -= 1
            bytesArray[i] = UInt8(value & (255))
            value = value >> 8
        } while (i > 0)
        return bytesArray
    }

    public var bytesForTwo: [UInt8] {
        return [UInt8(self & 0xff), UInt8(self >> 8 & 0xff)]
    }
}

extension Data: BytesConvertible {
    public var bytes: [UInt8] {
        var _bytes = [UInt8](repeating: 0, count: count)
        copyBytes(to: &_bytes, count: count)
        return _bytes
    }
}

extension String: BytesConvertible {
    public var bytes: [UInt8] {
        return utf8.map { $0 }
    }
}

extension CharacterSet {
    public static var hexStringAllowed: CharacterSet {
        return CharacterSet(charactersIn: "0123456789ABCDEFabcdef")
    }
}

extension String {
    public var isValidHexString: Bool {
        guard !self.isEmpty else {
            return false
        }
        let charset = CharacterSet.hexStringAllowed

        for scalar in self.unicodeScalars {
            guard charset.contains(scalar) else {
                return false
            }
        }
        return true
    }
}

extension BytesConvertible {
    public var hexString: String {
        return bytes.map { String(format: "%02x", $0) }.joined()
    }
}

extension Array {
    public static func bytes(fromHexString hexString: String) -> [UInt8]? {
        guard hexString.isValidHexString else {
            return nil
        }
        guard let regex = try? NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive) else {
            return nil
        }
        var array = [UInt8]()
        var hasFailure = false

        regex.enumerateMatches(in: hexString,
                               options: [],
                               range: NSRange(location: 0, length: hexString.count)) { (match, _, _) in
                                guard let match = match else {
                                    hasFailure = true
                                    return
                                }

                                let rangeStart = hexString.index(hexString.startIndex, offsetBy: match.range.location)
                                let rangeEnd = hexString.index(rangeStart, offsetBy: match.range.length)

                                let byteString = hexString[rangeStart..<rangeEnd]

                                guard let num = UInt8(byteString, radix: 16) else {
                                    hasFailure = true
                                    return
                                }
                                array.append(num)
        }

        if hasFailure || array.count <= 0 {
            return nil
        }
        return array
    }
}

extension Data {
    public init?(hexString: String) {
        guard let bytes = [UInt8].bytes(fromHexString: hexString) else {
            return nil
        }
        self = Data(bytes: bytes)
    }
}
