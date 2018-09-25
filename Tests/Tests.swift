//
//  Tests.swift
//  Tests
//
//  Created by sintaiyuan on 9/25/18.
//  Copyright © 2018 matanwrites. All rights reserved.
//

import XCTest
import Scuba


class Tests: XCTestCase {
    var sut: Scuba!
    let queue = DispatchQueue(label: #file)

    override func setUp() {
        sut = Scuba(processingQueue: queue)
    }

    func test_fill_enqueue() {
        let input = "bla"
        sut.fill(obj: input)
        syncQueue(queue)
        XCTAssertEqual(input, sut.peek()! as! String)
    }

    func test_take_popsFirst() {
        let input = "bla"
        sut.fill(obj: input)
        syncQueue(queue)
        XCTAssertEqual(input, sut.take() as! String)
        XCTAssertNil(sut.peek())
    }
}
