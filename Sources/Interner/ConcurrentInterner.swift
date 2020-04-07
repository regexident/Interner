import Foundation

public final class ConcurrentInterner<Interner>
where
    Interner: InternerProtocol
{
    private let interner: Interner

    private let queue: DispatchQueue = .init(
        label: String(describing: ConcurrentInterner.self),
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

extension ConcurrentInterner: InternerProtocol
where
    Interner: InternerProtocol
{
    public typealias Key = Interner.Key
    public typealias Identifier = Interner.Identifier

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

    public func interned(_ key: Key) -> Symbol {
        self.queue.sync(flags: .barrier) {
            self.interner.interned(key)
        }
    }

    public func lookup(_ symbol: Symbol) -> Key? {
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

extension ConcurrentInterner: Sequence
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
