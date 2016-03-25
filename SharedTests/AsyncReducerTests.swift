/* This Source Code Form is subject to the terms of the Mozilla Public
* License, v. 2.0. If a copy of the MPL was not distributed with this
* file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest
import Deferred
@testable import Shared

private let timeoutPeriod: NSTimeInterval = 600

class AsyncReducerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSimpleBehaviour() {
        let expectation = expectationWithDescription(__FUNCTION__)
        happyCase(expectation, combine: simpleAdder)
    }

    func testWaitingFillerBehaviour() {
        let expectation = expectationWithDescription(__FUNCTION__)
        happyCase(expectation, combine: waitingFillingAdder)
    }

    func testWaitingFillerAppendingBehaviour() {
        let expectation = expectationWithDescription(__FUNCTION__)
        appendingCase(expectation, combine: waitingFillingAdder)
    }

    func testFailingCombine() {
        let expectation = expectationWithDescription(__FUNCTION__)
        let combine = { (a: Int, b: Int) -> Deferred<Maybe<Int>> in
            if a >= 6 {
                return deferMaybe(TestError())
            }
            return deferMaybe(a + b)
        }
        let reducer = AsyncReducer(initialValue: 0, combine: combine)
        reducer.terminal.upon { res in
            XCTAssert(res.isFailure)
            expectation.fulfill()
        }

        self.append(reducer, items: 1, 2, 3, 4, 5)
        waitForExpectationsWithTimeout(timeoutPeriod, handler: nil)
    }

    func testFailingAppend() {
        let expectation = expectationWithDescription(__FUNCTION__)

        let reducer = AsyncReducer(initialValue: 0, combine: simpleAdder)
        reducer.terminal.upon { res in
            XCTAssert(res.isSuccess)
            XCTAssertEqual(res.successValue!, 15)
        }

        self.append(reducer, items: 1, 2, 3, 4, 5)

        delay(0.1) {
            do {
                try reducer.append(6, 7, 8)
                XCTFail("Can't append to a reducer that's already finished")
            } catch let error {
                XCTAssert(true, "Properly received error on finished reducer \(error)")
            }
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(timeoutPeriod, handler: nil)
    }
}

extension AsyncReducerTests {
    func happyCase(expectation: XCTestExpectation, combine: (Int, Int) -> Deferred<Maybe<Int>>) {
        let reducer = AsyncReducer(initialValue: 0, combine: combine)
        reducer.terminal.upon { res in
            XCTAssert(res.isSuccess)
            XCTAssertEqual(res.successValue!, 15)
            expectation.fulfill()
        }

        self.append(reducer, items: 1, 2, 3, 4, 5)
        waitForExpectationsWithTimeout(timeoutPeriod, handler: nil)
    }

    func appendingCase(expectation: XCTestExpectation, combine: (Int, Int) -> Deferred<Maybe<Int>>) {
        let reducer = AsyncReducer(initialValue: 0, combine: combine)
        reducer.terminal.upon { res in
            XCTAssert(res.isSuccess)
            XCTAssertEqual(res.successValue!, 15)
            expectation.fulfill()
        }

        self.append(reducer, items: 1, 2)

        delay(0.1) {
            self.append(reducer, items: 3, 4, 5)
        }
        waitForExpectationsWithTimeout(timeoutPeriod, handler: nil)
    }

    func append(reducer: AsyncReducer<Int, Int>, items: Int...) {
        do {
            try reducer.append(items)
        } catch let error {
            XCTFail("Append failed with \(error)")
        }
    }
}

class TestError: MaybeErrorType {
    var description = "Error"
}

private let serialQueue = dispatch_queue_create("com.mozilla.test.serial", DISPATCH_QUEUE_SERIAL)
private let concurrentQueue = dispatch_queue_create("com.mozilla.test.concurrent", DISPATCH_QUEUE_CONCURRENT)

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        concurrentQueue, closure)
}

private func simpleAdder(a: Int, b: Int) -> Deferred<Maybe<Int>> {
    return deferMaybe(a + b)
}

private func waitingFillingAdder(a: Int, b: Int) -> Deferred<Maybe<Int>> {
    let deferred = Deferred<Maybe<Int>>()
    delay(0.1) {
        deferred.fill(Maybe(success: a + b))
    }
    return deferred
}


