import Vector

extension Matrix: Swift::AdditiveArithmetic where Scalar: Swift::AdditiveArithmetic {
    public static var zero: Self { Self(repeating: .zero) }
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(rows: InlineArray { row in InlineArray { column in lhs[row, column] + rhs[row, column] } })
    }
    public static func - (lhs: Self, rhs: Self) -> Self {
        Self(rows: InlineArray { row in InlineArray { column in lhs[row, column] - rhs[row, column] } })
    }
}
