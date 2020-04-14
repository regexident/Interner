/// A thin shim around base identifiers.
///
/// Only interners can create instances of this type.
public struct GenericSymbol<RawValue> {
    internal let rawValue: RawValue

    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
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
