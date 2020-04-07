public final class Interner<T>
where
    T: Hashable
{
    public typealias Key = T
    public typealias Identifier = Int

    private var dictionary: [Key: Symbol]
    private var array: [Key]?

    /// Creates an interner.
    ///
    /// Use `.init(cachingLookup: false)` if you do not need to reverse-lookup symbols once they have been symbol.
    ///
    /// Otherwise use `.init(cachingLookup: true)`, but note that this forces every key to be stored twice.
    ///
    /// - Parameters:
    ///   - cachingLookup: `true` if the interner should keep a separate array
    ///     for reverse key lookup, otherwise `false`.
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

    public func interned(_ key: Key) -> Symbol {
        if let symbol = self.dictionary[key] {
            return symbol
        }

        let index = self.dictionary.count
        let symbol = Symbol(index)
        
        self.dictionary[key] = symbol
        self.array?.append(key)

//        assert(self.interned(key) == symbol)
//        assert(self.lookup(symbol) == key)

        return symbol
    }

    public func intern(_ key: Key) {
        let _ = self.interned(key)
    }

    public func lookup(_ symbol: Symbol) -> Key? {
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

    private func expensiveLinearLookup(_ symbol: Symbol) -> Key? {
        let keyAndSymbolOrNil = self.dictionary.first { key, value in
            value == symbol
        }

        return keyAndSymbolOrNil?.key
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
    public typealias Element = (key: Key, value: Symbol)
    public typealias Iterator = AnyIterator<Element>

    public func makeIterator() -> Iterator {
        return AnyIterator(self.dictionary.makeIterator())
    }
}
