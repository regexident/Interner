/// A thin shim around base identifiers.
///
/// Only interners can create instances of this type.
public struct GenericSymbol<ID> {
    public let id: ID

    internal init(_ id: ID) {
        self.id = id
    }
}

extension GenericSymbol: Identifiable where ID: Hashable {}

extension GenericSymbol: Hashable where ID: Hashable {}

extension GenericSymbol: Equatable where ID: Equatable {}

extension GenericSymbol: CustomStringConvertible
where
    ID: CustomStringConvertible
{
    public var description: String {
        self.id.description
    }
}

extension GenericSymbol: CustomDebugStringConvertible
where
    ID: CustomDebugStringConvertible
{
    public var debugDescription: String {
        let id = self.id.debugDescription
        return "Symbol(\(id))"
    }
}
