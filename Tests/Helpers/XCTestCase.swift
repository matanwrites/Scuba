//
//  XCTestCase.swift
//  Tests
//
//  Created by sintaiyuan on 9/25/18.
//  Copyright © 2018 matanwrites. All rights reserved.
//

import XCTest


extension XCTestCase {
    func syncQueue(_ queue: DispatchQueue) {
        for _ in 0..<5 {
            queue.sync {}
        }
    }
}
