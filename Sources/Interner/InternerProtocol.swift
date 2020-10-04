// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

/// Caches objects efficiently, with minimal memory footprint and associates them with unique symbols.
///
/// These symbols allow constant time comparisons and look-ups to the underlying symbol objects.
public protocol InternerProtocol: AnyObject {
    associatedtype Object
    associatedtype Symbol

    /// Returns the number of unique symbols.
    var count: Int { get }

    /// Returns `true` if the number of unique symbols is zero, otherwise `false`.
    var isEmpty: Bool { get }

    /// Returns the corresponding symbol for a object.
    /// - Parameters:
    ///   - object: The object to intern.
    func interned(_ object: Object) -> Symbol

    /// Looks up a object from its symbol, returning it if found, otherwise `nil`.
    /// - Parameters:
    ///   - symbol: The symbol to look up the corresponding object for.
    func lookup(_ symbol: Symbol) -> Object?

    /// Reserves enough space to store the specified number of objects.
    /// - Parameters:
    ///   - minimumCapacity: The requested number of objects to store.
    func reserveCapacity(_ minimumCapacity: Int)

    /// Removes all objects from the interner.
    /// - Parameters:
    ///   - keepCapacity: Pass `true` to keep the existing capacity
    ///     of the interner after removing its objects.
    func removeAll(keepingCapacity keepCapacity: Bool)
}

extension InternerProtocol {
    /// Adds a object to the interner without returning an symbol.
    /// - Parameters:
    ///   - object: The object to intern.
    public func intern(_ object: Object) {
        let _ = self.interned(object)
    }

    /// Looks up a object from its symbol, or crashes if not found.
    /// - Parameters:
    ///   - symbol: The symbol to look up the corresponding object for.
    public func lookupUnchecked(_ symbol: Symbol) -> Object {
        guard let object = self.lookup(symbol) else {
            fatalError("Failed to look up symbol '\(symbol)'")
        }

        return object
    }
}
