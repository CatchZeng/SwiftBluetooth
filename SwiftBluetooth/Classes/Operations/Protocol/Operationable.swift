//
//  Operationable.swift
//  SwiftBluetooth
//
//  Created by CatchZeng on 2017/12/28.
//

import Foundation

public enum OperationState {
    case notStarted
    case running
    case cancelling
    case cancelled
    case failed(Error?)
    case completed
    
    var isFinished: Bool {
        switch self {
        case .completed, .cancelled, .failed:
            return true
        default:
            return false
        }
    }
}

protocol Operationable {
    var state: OperationState { get }
    
    func start()
    
    @discardableResult
    func process(event: Event) -> Any?
    
    func cancel()
    
    func fail(_ error: Error?)
    
    func success()
}

open class BLEOperation: Operationable {
    var state: OperationState = .notStarted
    
    func start() {
        state = .running
    }
    
    @discardableResult
    func process(event: Event) -> Any? {
        return nil
    }
    
    func cancel() {
        state = .cancelled
    }
    
    func fail(_ error: Error?) {
        state = .failed(error)
    }
    
    func success() {
        state = .completed
    }
}
