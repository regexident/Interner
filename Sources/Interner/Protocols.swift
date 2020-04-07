/// Caches objects efficiently, with minimal memory footprint and associates them with unique symbols.
///
/// These symbols allow constant time comparisons and look-ups to the underlying symbol objects.
public protocol InternerProtocol: AnyObject {
    associatedtype Key
    associatedtype Identifier

    typealias Symbol = GenericSymbol<Identifier>

    /// Returns the number of unique symbols.
    var count: Int { get }

    /// Returns `true` if the number of unique symbols is zero, otherwise `false`.
    var isEmpty: Bool { get }

    /// Returns the corresponding symbol for a key.
    /// - Parameters:
    ///   - key: The key to intern.
    func interned(_ key: Key) -> Symbol

    /// Looks up a key from its symbol, returning it if found, otherwise `nil`.
    /// - Parameters:
    ///   - symbol: The symbol to look up the corresponding key for.
    func lookup(_ symbol: Symbol) -> Key?

    /// Reserves enough space to store the specified number of keys.
    /// - Parameters:
    ///   - minimumCapacity: The requested number of keys to store.
    func reserveCapacity(_ minimumCapacity: Int)

    /// Removes all keys from the interner.
    /// - Parameters:
    ///   - keepCapacity: Pass `true` to keep the existing capacity
    ///     of the interner after removing its keys.
    func removeAll(keepingCapacity keepCapacity: Bool)
}

extension InternerProtocol {
    /// Adds a key to the interner without returning an symbol.
    /// - Parameters:
    ///   - key: The key to intern.
    public func intern(_ key: Key) {
        let _ = self.interned(key)
    }

    /// Looks up a key from its symbol, or crashes if not found.
    /// - Parameters:
    ///   - symbol: The symbol to look up the corresponding key for.
    public func lookupUnchecked(_ symbol: Symbol) -> Key {
        self.lookup(symbol)!
    }
}
