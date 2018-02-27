//
//  WriteBuffer.swift
//  SwiftBluetooth
//
//  Created by CatchZeng on 2017/12/28.
//

import Foundation

open class WriteBuffer {
    public var timeInterval: TimeInterval = 0.01
    
    private var operations = [WriteOperation]()
    private var lock = NSLock()
    private var timer: Timer?
    
    public func add(operation: WriteOperation) {
        lock.lock()
        operations.append(operation)
        lock.unlock()
        
        startTimer()
    }
    
    private func startTimer() {
        stopTimer()
        
        timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                     target: self,
                                     selector: #selector(send),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    private func stopTimer() {
        timer?.invalidate()
    }
    
    @objc private func send() {
        if operations.count < 1 {
            stopTimer()
            return
        }
        
        lock.lock()
        let operation = operations.first
        operations.removeFirst()
        lock.unlock()
        
        operation?.start()
    }
}
