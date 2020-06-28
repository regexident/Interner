// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

/// A general purpose thread-safe object interner.
///
/// Important: For single-threaded use-cases you should use `ThreadsafeInterner<Interner<T>>` instead.
public final class ThreadsafeInterner<Interner>
where
    Interner: InternerProtocol
{
    private let interner: Interner

    private let queue: DispatchQueue = .init(
        label: String(describing: ThreadsafeInterner.self),
        attributes: .concurrent
    )

    /// Creates a thread-safe, concurrent interner by decorating a
    /// non-thread-safe interner with a read-efficient dispatch queue
    /// with readers–writer lock semantics:
    /// - Parameter interner: A non-thread-safe interner.
    public init(interner: Interner) {
        self.interner = interner
    }
}

extension ThreadsafeInterner: InternerProtocol
where
    Interner: InternerProtocol
{
    public typealias Object = Interner.Object
    public typealias Symbol = Interner.Symbol

    public var count: Int {
        self.queue.sync {
            self.interner.count
        }
    }

    public var isEmpty: Bool {
        self.queue.sync {
            self.interner.isEmpty
        }
    }

    public func interned(_ object: Object) -> Symbol {
        self.queue.sync(flags: .barrier) {
            self.interner.interned(object)
        }
    }

    public func lookup(_ symbol: Symbol) -> Object? {
        self.queue.sync {
            self.interner.lookup(symbol)
        }
    }

    public func reserveCapacity(_ minimumCapacity: Int) {
        self.queue.sync(flags: .barrier) {
            self.interner.reserveCapacity(minimumCapacity)
        }
    }

    public func removeAll(keepingCapacity keepCapacity: Bool = false) {
        self.queue.sync(flags: .barrier) {
            self.interner.removeAll(keepingCapacity: keepCapacity)
        }
    }
}

extension ThreadsafeInterner: Sequence
where
    Interner: Sequence
{
    public typealias Element = Interner.Element
    public typealias Iterator = Interner.Iterator

    public func makeIterator() -> Iterator {
        self.queue.sync {
            self.interner.makeIterator()
        }
    }
}
