/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Deferred
// Haskell, baby.

// Monadic bind/flatMap operator for Deferred.
infix operator >>== { associativity left precedence 160 }
public func >>== <T, U>(x: Deferred, f: T -> Deferred) -> Deferred {
    return chainDeferred(x, f: f)
}

// A termination case.
public func >>== <T>(x: Deferred, f: T -> ()) {
    return x.upon { result in
        if let v = result.successValue {
            f(v)
        }
    }
}

// Monadic `do` for Deferred.
infix operator >>> { associativity left precedence 150 }
public func >>> <T, U>(x: Deferred, f: () -> Deferred) -> Deferred {
    return x.bind { res in
        if res.isSuccess {
            return f()
        }
        return deferMaybe(res.failureValue!)
    }
}

// Another termination case.
public func >>> <T>(x: Deferred, f: () -> ())  {
    return x.upon { res in
        if res.isSuccess {
            f()
        }
    }
}

/**
* Returns a thunk that return a Deferred that resolves to the provided value.
*/
public func always<T>(t: T) -> () -> Deferred {
    return { deferMaybe(t) }
}

public func deferMaybe<T>(s: T) -> Deferred {
    return Deferred(value: Maybe(success: s))
}

public func deferMaybe<T>(e: MaybeErrorType) -> Deferred {
    return Deferred(value: Maybe(failure: e))
}

public typealias Success = Deferred

public func succeed() -> Success {
    return deferMaybe(())
}

/**
 * Return a single Deferred that represents the sequential chaining
 * of f over the provided items.
 */
public func walk<T>(items: [T], f: T -> Success) -> Success {
    return items.reduce(succeed()) { success, item -> Success in
        success >>> { f(item) }
    }
}

/**
 * Like `all`, but thanks to its taking thunks as input, each result is
 * generated in strict sequence. Fails immediately if any result is failure.
 */
public func accumulate<T>(thunks: [() -> Deferred]) -> Deferred {
    if thunks.isEmpty {
        return deferMaybe([])
    }

    let combined = Deferred
    var results: [T] = []
    results.reserveCapacity(thunks.count)

    var onValue: (T -> ())!
    var onResult: (Maybe<T> -> ())!

    onValue = { t in
        results.append(t)
        if results.count == thunks.count {
            combined.fill(Maybe(success: results))
        } else {
            thunks[results.count]().upon(onResult)
        }
    }

    onResult = { r in
        if r.isFailure {
            combined.fill(Maybe(failure: r.failureValue!))
            return
        }
        onValue(r.successValue!)
    }

    thunks[0]().upon(onResult)

    return combined
}

/**
 * Take a function and turn it into a side-effect that can appear
 * in a chain of async operations without producing its own value.
 */
public func effect<T, U>(f: T -> U) -> T -> Deferred {
    return { t in
        f(t)
        return deferMaybe(t)
    }
}

/**
 * Return a single Deferred that represents the sequential chaining of
 * f over the provided items, with the return value chained through.
 */
public func walk<T, U>(items: [T], start: Deferred, f: (T, U) -> Deferred) -> Deferred {
    let fs = items.map { item in
        return { val in
            f(item, val)
        }
    }
    return fs.reduce(start, combine: >>==)
}

/**
 * Like `all`, but doesn't accrue individual values.
 */
extension Array where Element: Success {
    public func allSucceed() -> Success {
        return all(self).bind { results -> Success in
            if let failure = results.find({ $0.isFailure }) {
                return deferMaybe(failure.failureValue!)
            }

            return succeed()
        }
    }
}

public func chainDeferred<T, U>(a: Deferred, f: T -> Deferred) -> Deferred {
    return a.bind { res in
        if let v = res.successValue {
            return f(v)
        }
        return Deferred(value: Maybe<U>(failure: res.failureValue!))
    }
}

public func chainResult<T, U>(a: Deferred, f: T -> Maybe<U>) -> Deferred {
    return a.map { res in
        if let v = res.successValue {
            return f(v)
        }
        return Maybe<U>(failure: res.failureValue!)
    }
}

public func chain<T, U>(a: Deferred, f: T -> U) -> Deferred {
    return chainResult(a, f: { Maybe<U>(success: f($0)) })
}

/// Defer-ifies a block to an async dispatch queue.
public func deferDispatchAsync<T>(queue: dispatch_queue_t, f: () -> Deferred) -> Deferred {
    let deferred = Deferred
    dispatch_async(queue, {
        f().upon { result in
            deferred.fill(result)
        }
    })

    return deferred
}
