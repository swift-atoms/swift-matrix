public import Vector

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

extension Matrix: Swift.Sendable where Scalar: Swift.Sendable {}

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
