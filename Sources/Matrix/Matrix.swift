public import Vector

public struct Matrix<let Rows: Int, let Columns: Int, Scalar> {
    public var rows: InlineArray<Rows, InlineArray<Columns, Scalar>>

    @inlinable
    public init(rows: consuming InlineArray<Rows, InlineArray<Columns, Scalar>>) {
        self.rows = rows
    }
}

extension Matrix: Swift::Sendable where Scalar: Swift::Sendable {}

extension Matrix where Scalar: Numeric {
    @inlinable
    public func applied(to vector: Vector<Columns, Scalar>) -> Vector<Rows, Scalar> {
        Vector<Rows, Scalar>(
            InlineArray { row in
                var result: Scalar = .zero
                (0..<Columns).forEach { column in result += self[row, column] * vector[column] }
                return result
            }
        )
    }

    @inlinable
    public func multiplied<let OtherColumns: Int>(
        by other: Matrix<Columns, OtherColumns, Scalar>
    ) -> Matrix<Rows, OtherColumns, Scalar> {
        Matrix<Rows, OtherColumns, Scalar>(
            rows: InlineArray { row in
                InlineArray { column in
                    var result: Scalar = .zero
                    (0..<Columns).forEach { inner in result += self[row, inner] * other[inner, column] }
                    return result
                }
            }
        )
    }
}

extension Matrix {
    @inlinable
    public init(repeating value: Scalar) {
        self.init(rows: InlineArray(repeating: InlineArray(repeating: value)))
    }
}

extension Matrix {

    @inlinable
    public subscript(row: Int, column: Int) -> Scalar {
        get { rows[row][column] }
        set { rows[row][column] = newValue }
    }

    @inlinable
    public var transposed: Matrix<Columns, Rows, Scalar> {
        Matrix<Columns, Rows, Scalar>(
            rows: InlineArray { column in
                InlineArray { row in self[row, column] }
            }
        )
    }
}

extension Matrix: Swift::AdditiveArithmetic where Scalar: Swift::AdditiveArithmetic {
    @inlinable
    public static var zero: Self { Self(repeating: .zero) }
    @inlinable
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(rows: InlineArray { row in InlineArray { column in lhs[row, column] + rhs[row, column] } })
    }
    @inlinable
    public static func - (lhs: Self, rhs: Self) -> Self {
        Self(rows: InlineArray { row in InlineArray { column in lhs[row, column] - rhs[row, column] } })
    }
}

extension Matrix: Swift::Equatable where Scalar: Swift::Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        for row in 0..<Rows {
            for column in 0..<Columns where lhs[row, column] != rhs[row, column] { return false }
        }
        return true
    }
}

extension Matrix: Swift::Hashable where Scalar: Swift::Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        (0..<Rows).forEach { row in
            (0..<Columns).forEach { column in hasher.combine(self[row, column]) }
        }
    }
}
