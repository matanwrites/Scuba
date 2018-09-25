//
//  Scuba.swift
//  Scuba
//
//  Created by sintaiyuan on 9/25/18.
//  Copyright © 2018 matanwrites. All rights reserved.
//

import Foundation


public class Scuba {
    public static let shared = Scuba()


    public init (processingQueue: DispatchQueue = DispatchQueue(label: "scuba.processing.serial.queue")) {
        self.processingQ = processingQueue
    }


    // MARK: - Consts
    public let processingQ: DispatchQueue


    // MARK: - States
    private var storage = [Any]()
}


// MARK: - Producing
extension Scuba {
    public func fill(obj: Any) {
        processingQ.async { [weak self] in
            self?.storage.append(obj)
        }
    }
}


// MARK: - Consuming
extension Scuba {
    public func peek() -> Any? {
        return processingQ.sync {
            storage.first
        }
    }


    /// Pop first element from the queue
    /// - Raise an exception if the queue is empty use peek() first
    /// - Returns: element enqueued in the Scuba
    public func take() -> Any {
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
