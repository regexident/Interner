// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

/// A general purpose thread-safe object interner.
///
/// Important: For single-threaded use-cases you should use `ThreadsafeInterner<Interner<T>>` instead.
public final class ThreadsafeInterner<Extern, Intern>
where
    Extern: Hashable,
    Intern: FixedWidthInteger & BinaryInteger & UnsignedInteger
{
    public typealias Base = Interner<Extern, Intern>

    private let base: Interner<Extern, Intern>

    private let queue: DispatchQueue = .init(
        label: String(describing: ThreadsafeInterner.self),
        attributes: .concurrent
    )

    /// Creates a thread-safe, concurrent interner by decorating a
    /// non-thread-safe interner with a read-efficient dispatch queue
    /// with readers–writer lock semantics:
    /// - Parameter interner: A non-thread-safe interner.
    public init(_ base: Base = .init()) {
        self.base = base
    }

    public convenience init(
        efficientFor efficiencyMode: Base.EfficiencyMode = .time
    ) {
        self.init(.init(efficientFor: efficiencyMode))
    }
}

extension ThreadsafeInterner: InternerProtocol
where
    Extern: Hashable,
    Intern: FixedWidthInteger & BinaryInteger & UnsignedInteger
{
    public typealias Object = Base.Object
    public typealias Symbol = Base.Symbol
    public typealias Error = Base.Error

    public var count: Int {
        self.queue.sync {
            self.base.count
        }
    }

    public var isEmpty: Bool {
        self.queue.sync {
            self.base.isEmpty
        }
    }

    public func interned(_ object: Object) -> Symbol {
        self.queue.sync(flags: .barrier) {
            self.base.interned(object)
        }
    }

    public func lookup(_ symbol: Symbol) -> Object? {
        self.queue.sync {
            self.base.lookup(symbol)
        }
    }

    public func reserveCapacity(_ minimumCapacity: Int) {
        self.queue.sync(flags: .barrier) {
            self.base.reserveCapacity(minimumCapacity)
        }
    }

    public func removeAll(keepingCapacity keepCapacity: Bool = false) {
        self.queue.sync(flags: .barrier) {
            self.base.removeAll(keepingCapacity: keepCapacity)
        }
    }
}

extension ThreadsafeInterner: Sequence {
    public typealias Element = Base.Element
    public typealias Iterator = Base.Iterator

    public func makeIterator() -> Iterator {
        self.queue.sync {
            self.base.makeIterator()
        }
    }
}
