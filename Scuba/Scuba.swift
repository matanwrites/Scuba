//
//  Scuba.swift
//  Scuba
//
//  Created by sintaiyuan on 9/25/18.
//  Copyright © 2018 matanwrites. All rights reserved.
//

import Foundation


public class Scuba {
    public init (processingQueue: DispatchQueue = DispatchQueue(label: "scuba.processing.serial.queue")) {
        self.processingQ = processingQueue
    }

    deinit {
        processingQ.async { [weak self] in
            self?.onNext = nil
        }
    }

    // MARK: - Consts
    public let processingQ: DispatchQueue


    // MARK: - States
    private var storage = [ScubaValue]()
    
    public func peek() -> ScubaValue? {
        return processingQ.sync {
            storage.first
        }
    }
    
    public func last() -> ScubaValue? {
        return processingQ.sync {
            storage.last
        }
    }
    
    // MARK: - Callbacks
    
    /// Called whenever a new value is added to the pipe
    /// - Consumes a value in the pipe
    /// - Only stream the values starting from when the callback is set
    /// - Stop streaming if the scuba is dealloced
    public var onNext: ScubaValueBlock?
}


// MARK: - Producing
extension Scuba {
    public func fill(obj: ScubaValue) {
        processingQ.async { [weak self] in
            self?.storage.append(obj)
            self?.notifyOnNext()
        }
    }
}


// MARK: - Consuming
extension Scuba {
    private func notifyOnNext() {
        guard let onNext = self.onNext else { return }
        onNext(storage.removeLast())
    }


    /// Pop first element from the queue
    /// - Raise an exception if the queue is empty use peek() first
    /// - Returns: element enqueued in the Scuba
    public func take() -> ScubaValue {
        return processingQ.sync {
            //this operation is O(n) for now, we need to implement a circular queue to optimize this
            storage.removeFirst()
        }
    }
}


// MARK: - ?
extension Scuba {
    public func flush() {
        storage.removeAll()
    }
}


// MARK: - Types
public typealias ScubaValueBlock = (ScubaValue) -> Void
public typealias ScubaValue = Any
