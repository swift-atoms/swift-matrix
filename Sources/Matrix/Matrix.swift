public import Vector

/// A rectangular matrix. Row and column dimensions are part of its type.
/// Multiplication requires matching inner dimensions at compile time.
public struct Matrix<let Rows: Int, let Columns: Int, Scalar> {
    public var rows: InlineArray<Rows, InlineArray<Columns, Scalar>>

    public init(rows: consuming InlineArray<Rows, InlineArray<Columns, Scalar>>) {
        self.rows = rows
    }

    public init(repeating value: Scalar) {
        self.rows = InlineArray(repeating: InlineArray(repeating: value))
    }

    public subscript(row: Int, column: Int) -> Scalar {
        get { rows[row][column] }
        set { rows[row][column] = newValue }
    }

    public var transposed: Matrix<Columns, Rows, Scalar> {
        Matrix<Columns, Rows, Scalar>(rows: InlineArray { column in
            InlineArray { row in self[row, column] }
        })
    }
}

extension Matrix: Sendable where Scalar: Sendable {}

extension Matrix: Equatable where Scalar: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        for row in 0..<Rows {
            for column in 0..<Columns where lhs[row, column] != rhs[row, column] { return false }
        }
        return true
    }
}

extension Matrix: Hashable where Scalar: Hashable {
    public func hash(into hasher: inout Hasher) {
        for row in 0..<Rows {
            for column in 0..<Columns { hasher.combine(self[row, column]) }
        }
    }
}

extension Matrix: AdditiveArithmetic where Scalar: AdditiveArithmetic {
    public static var zero: Self { Self(repeating: .zero) }
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(rows: InlineArray { row in InlineArray { column in lhs[row, column] + rhs[row, column] } })
    }
    public static func - (lhs: Self, rhs: Self) -> Self {
        Self(rows: InlineArray { row in InlineArray { column in lhs[row, column] - rhs[row, column] } })
    }
}

extension Matrix where Scalar: Numeric {
    public func applied(to vector: Vector<Columns, Scalar>) -> Vector<Rows, Scalar> {
        Vector<Rows, Scalar>(InlineArray { row in
            var result: Scalar = .zero
            for column in 0..<Columns { result += self[row, column] * vector[column] }
            return result
        })
    }

    public func multiplied<let OtherColumns: Int>(
        by other: Matrix<Columns, OtherColumns, Scalar>
    ) -> Matrix<Rows, OtherColumns, Scalar> {
        Matrix<Rows, OtherColumns, Scalar>(rows: InlineArray { row in
            InlineArray { column in
                var result: Scalar = .zero
                for inner in 0..<Columns { result += self[row, inner] * other[inner, column] }
                return result
            }
        })
    }
}
