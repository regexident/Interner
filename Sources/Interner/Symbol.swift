// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

/// A thin shim around base identifiers.
///
/// Only interners can create instances of this type.
public struct GenericSymbol<RawValue> {
    internal let rawValue: RawValue

    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public static func unchecked(rawValue: RawValue) -> Self {
        self.init(rawValue)
    }
}

extension GenericSymbol: Hashable where RawValue: Hashable {}

extension GenericSymbol: Equatable where RawValue: Equatable {}

extension GenericSymbol: CustomStringConvertible
where
    RawValue: CustomStringConvertible
{
    public var description: String {
        self.rawValue.description
    }
}

extension GenericSymbol: CustomDebugStringConvertible
where
    RawValue: CustomDebugStringConvertible
{
    public var debugDescription: String {
        let rawValue = String(reflecting: self.rawValue)
        return "Symbol(\(rawValue))"
    }
}
