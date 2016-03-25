/* This Source Code Form is subject to the terms of the Mozilla Public
* License, v. 2.0. If a copy of the MPL was not distributed with this
* file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Deferred

private let DefaultDispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

public func asyncReducer<T, U>(initialValue: T, combine: (T, U) -> Deferred<Maybe<T>>) -> AsyncReducer<T, U> {
    return AsyncReducer(initialValue: initialValue, combine: combine)
}

/**
 * A appendable, async `reduce`.
 * The reducer starts empty. New items need to be `append`ed.
 * The constructor takes an `initialValue`, a `dispatch_queue_t`, and a `combine` function.
 * The reduced value can be accessed via the `reducer.terminal` Deferred<Maybe<T>> which is runs once all items have been combined.
 * The terminal will not be filled if no items have been appended.
 * Once the terminal has been filled, no more items can be appeneded, and `append` methods will error.
 */
public class AsyncReducer<T, U> {

    public typealias Combine = (T, U) -> Deferred<Maybe<T>>

    private let initialValueDeferred: Deferred<Maybe<T>>

    private let dispatchQueue: dispatch_queue_t

    public let terminal: Deferred<Maybe<T>> = Deferred()

    private var queuedItems: [U] = []

    private var index = 0

    private let lock = NSRecursiveLock()

    private let combine: Combine

    private var isStarted: Bool {
        return index > 0 && queuedItems.count > 0
    }

    /**
     * Has this task queue finished.
     * Once the task queue has finished, it cannot have more tasks appended.
     */
    public var isFilled: Bool {
        lock.lock()
        defer { lock.unlock() }
        return terminal.isFilled
    }

    public convenience init(initialValue: T, queue: dispatch_queue_t = DefaultDispatchQueue, combine: Combine) {
        let starter = deferMaybe(initialValue)
        self.init(initialValue: starter, queue: queue, combine: combine)
    }

    public init(initialValue: Deferred<Maybe<T>>, queue: dispatch_queue_t = DefaultDispatchQueue, combine: Combine) {
        self.dispatchQueue = queue
        self.combine = combine
        self.initialValueDeferred = initialValue
    }

    // This is always protected by a lock, so we don't need to 
    // take another one.
    private func ensureStarted() {
        if isStarted {
            return
        }

        func queueNext(deferredValue: Deferred<Maybe<T>>) {
            deferredValue.uponQueue(dispatchQueue) { res in
                continueMaybe(res)
            }
        }

        func nextItem() -> U? {
            if  self.index < queuedItems.count {
                let value = queuedItems[self.index]
                self.index += 1
                return value
            }
            return nil
        }

        func continueMaybe(res: Maybe<T>) {
            lock.lock()
            defer { lock.unlock() }

            if res.isFailure {
                self.terminal.fill(Maybe(failure: res.failureValue!))
                return
            }

            let accumulator = res.successValue!

            guard let item = nextItem() else {
                self.terminal.fill(Maybe(success: accumulator))
                return
            }

            let combineItem = deferDispatchAsync(dispatchQueue) { _ in
                return self.combine(accumulator, item)
            }

            queueNext(combineItem)
        }

        queueNext(initialValueDeferred)
    }

    /**
     * Append one or more tasks on to the end of the queue.
     * Tasks are named with strings.
     * @throws AlreadyFilled if the queue has finished already.
     */
    public func append(items: U...) throws -> Deferred<Maybe<T>> {
        return try append(items)
    }

    /**
     * Append a list of tasks on to the end of the queue.
     * Tasks are named with strings.
     * @throws AlreadyFilled if the queue has finished already.
     */
    public func append(items: [U]) throws -> Deferred<Maybe<T>> {
        lock.lock()
        defer { lock.unlock() }

        if terminal.isFilled {
            throw ReducerError.AlreadyFilled
        }

        queuedItems.appendContentsOf(items)
        ensureStarted()

        return terminal
    }
}

enum ReducerError: ErrorType {
    case AlreadyFilled
}