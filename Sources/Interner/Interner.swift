// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

/// A general purpose object interner.
///
/// Important: For multi-threaded use-cases you should use `ThreadsafeInterner<Interner<T>>` instead.
public final class Interner<Extern, Intern>
where
    Extern: Hashable,
    Intern: FixedWidthInteger & BinaryInteger & UnsignedInteger
{
    /// The efficiency mode
    public enum EfficiencyMode {
        /// Optimized for time (i.e. CPU) efficiency
        case time
        /// Optimized for space (i.e. RAM) efficiency
        case space
    }

    public typealias Object = Extern
    public typealias Symbol = GenericSymbol<Intern>

    private var dictionary: [Object: Symbol]
    private var array: [Object]?

    /// Creates an interner for the provided efficiency-mode.
    ///
    /// ## Efficiency modes:
    ///
    /// - `.time`: This mode causes the interner to store each object twice,
    ///   which allows for `O(1)` symbol-to-object reverse-lookups.
    ///   (The upper-bound memory-overhead per element compared to `.space` is `2x`,
    ///   as the objects have to be stored twice.)
    ///
    /// - `.space`: This mode causes the interner to store each object only once,
    ///   which halfs the expected memory-usage compared to `.time`,
    ///   yet in turn leads to `O(N)` symbol-to-object reverse-lookups.
    ///   (The upper-bound memory-overhead per lookup compared to `.time` is `Nx`,
    ///   with `N` being the number of objects.)
    ///
    /// - Parameters:
    ///   - efficiencyMode: The efficienty mode to use. The default is `.time`.
    public required init(
        efficientFor efficiencyMode: EfficiencyMode = .time
    ) {
        self.dictionary = [:]
        switch efficiencyMode {
        case .time:
            self.array = []
        case .space:
            self.array = nil
        }
    }
}

extension Interner: Equatable
where
    Extern: Equatable,
    Intern: Equatable
{
    public static func == (lhs: Interner<Extern, Intern>, rhs: Interner<Extern, Intern>) -> Bool {
        guard lhs.dictionary == rhs.dictionary else {
            return false
        }
        guard lhs.array == rhs.array else {
            return false
        }
        return true
    }
}

extension Interner: Hashable
where
    Extern: Hashable,
    Intern: Hashable
{
    public func hash(into hasher: inout Hasher) {
        self.dictionary.hash(into: &hasher)
        self.array?.hash(into: &hasher)
    }
}

extension Interner: CustomReflectable {
    public var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "dictionary": self.dictionary,
                "array": self.array as Any,
            ],
            displayStyle: .struct
        )
    }
}

extension Interner {
    private func expensiveLinearLookup(_ symbol: Symbol) -> Object? {
        let objectAndSymbolOrNil = self.dictionary.first { key, value in
            value == symbol
        }

        return objectAndSymbolOrNil?.key
    }
}

extension Interner: InternerProtocol {
    public var count: Int {
        self.dictionary.count
    }

    public var isEmpty: Bool {
        self.dictionary.isEmpty
    }

    public func interned(_ object: Object) -> Symbol {
        if let symbol = self.dictionary[object] {
            return symbol
        }

        let index = self.dictionary.count
        guard let rawValue = Intern(exactly: index) else {
            fatalError("Out of bounds: \(index) not in \(Intern.min)...\(Intern.max)")
        }
        let symbol = Symbol(rawValue)
        
        self.dictionary[object] = symbol
        self.array?.append(object)

        assert(self.interned(object) == symbol)
        assert(self.lookup(symbol) == object)

        return symbol
    }

    public func intern(_ object: Object) {
        let _ = self.interned(object)
    }

    public func lookup(_ symbol: Symbol) -> Object? {
        guard let array = self.array else {
            // Fall back to expensive linear-search lookup:
            return self.expensiveLinearLookup(symbol)
        }

        let rawValue = symbol.rawValue
        guard let index = Int(exactly: rawValue) else {
            fatalError("Out of bounds: \(rawValue) not in \(Int.min)...\(Int.max)")
        }

        guard index < array.count else {
            return nil
        }

        return array[index]
    }

    public func reserveCapacity(_ minimumCapacity: Int) {
        self.dictionary.reserveCapacity(minimumCapacity)
        self.array?.reserveCapacity(minimumCapacity)
    }

    public func removeAll(keepingCapacity keepCapacity: Bool = false) {
        self.dictionary.removeAll(keepingCapacity: keepCapacity)
    }
}

extension Interner: Sequence {
    public typealias Element = (key: Object, value: Symbol)
    public typealias Iterator = AnyIterator<Element>

    public func makeIterator() -> Iterator {
        return AnyIterator(self.dictionary.makeIterator())
    }
}
