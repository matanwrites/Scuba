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
        sut.fill(obj: input); syncQueue(queue)
        XCTAssertEqual(input, sut.peek()! as! String)
    }

    func test_take_dequeue() {
        let input = "bla"
        sut.fill(obj: input);
        XCTAssertEqual(input, sut.take() as! String)
        XCTAssertNil(sut.peek())
    }
}


extension Tests {
    func test_onNext_callback_and_consume() {
        var i = 0
        var input = ["a", "b"]
        
        let onNextValue: (Any) -> Void = { v in
            XCTAssertEqual(input[i], v as! String)
            i += 1
        }
        sut.onNext = onNextValue

        sut.fill(obj: input[i]); syncQueue(queue)
        XCTAssertNil(sut.peek())
        
        sut.fill(obj: input[i]); syncQueue(queue)
        XCTAssertNil(sut.peek())
    }
    
    func test_onNext_receives_data_only_since_callback_set() {
        var i = 0
        var input = ["a", "b", "c"]
        let firstValue = input[0]
        
        sut.fill(obj: input[i])
        syncQueue(queue)
        
        let onNextValue: (ScubaValue) -> Void = { v in
            XCTAssertEqual(input[i], v as! String)
        }
        sut.onNext = onNextValue
        
        i += 1
        sut.fill(obj: input[i]); syncQueue(queue)
        
        XCTAssertEqual(sut.peek() as! String, firstValue)
        
        i += 1
        sut.fill(obj: input[i]); syncQueue(queue)
        XCTAssertEqual(sut.peek() as! String, firstValue)
    }
    
    func test_onNext_stops_receiving_data_when_callback_removed() {
        var i = 0
        var input = ["a", "b", "c", "d"]
        let thirdValue = input[2]
        let lastValue = input[3]
        
        let onNextValue: (ScubaValue) -> Void = { v in
            XCTAssertEqual(input[i], v as! String)
        }
        sut.onNext = onNextValue
        
        sut.fill(obj: input[i]); syncQueue(queue)
        i += 1

        sut.fill(obj: input[i]); syncQueue(queue)
        i += 1
        
        sut.onNext = nil
        sut.fill(obj: thirdValue); syncQueue(queue)
        XCTAssertEqual(sut.peek() as! String, thirdValue)
        
        
        sut.fill(obj: lastValue); syncQueue(queue)
        XCTAssertEqual(sut.peek() as! String, thirdValue)
        XCTAssertEqual(sut.last() as! String, lastValue)
    }
    
    func test_deinit_removes_callback() {
        var i = 0
        var input = ["a", "b", "c", "d"]
        let thirdValue = input[2]
        
        let onNextValue: (ScubaValue) -> Void = { v in
            XCTAssertEqual(input[i], v as! String)
        }
        sut.onNext = onNextValue
        
        sut.fill(obj: input[i]); syncQueue(queue)
        i += 1
        
        sut.fill(obj: input[i]); syncQueue(queue)
        i += 1
        
        sut.fill(obj: thirdValue);
        i += 1
        sut = nil
        syncQueue(queue)
    }
}
