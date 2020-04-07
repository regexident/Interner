public final class Interner<T>
where
    T: Hashable
{
    public typealias Object = T
    public typealias Symbol = GenericSymbol<Int>

    private var dictionary: [Object: Symbol]
    private var array: [Object]?

    /// Creates an interner.
    ///
    /// Use `.init(cachingLookup: false)` if you do not need to reverse-lookup symbols once they have been symbol.
    ///
    /// Otherwise use `.init(cachingLookup: true)`, but note that this forces every object to be stored twice.
    ///
    /// - Parameters:
    ///   - cachingLookup: `true` if the interner should keep a separate array
    ///     for reverse object lookup, otherwise `false`.
    public required init(cachingLookup: Bool) {
        self.dictionary = [:]
        self.array = cachingLookup ? [] : nil
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
        let symbol = Symbol(index)
        
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

        let index = symbol.id

        guard index < array.count else {
            return nil
        }

        return array[index]
    }

    private func expensiveLinearLookup(_ symbol: Symbol) -> Object? {
        let objectAndSymbolOrNil = self.dictionary.first { key, value in
            value == symbol
        }

        return objectAndSymbolOrNil?.key
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
