extension Matrix where Rows == 4, Columns == 4, Scalar: Numeric {

    @inlinable
    public init(linear: Matrix<3, 3, Scalar>, translation: Vector<3, Scalar> = .zero) {
        self.init(
            rows: [
                [linear[0, 0], linear[0, 1], linear[0, 2], translation[0]],
                [linear[1, 0], linear[1, 1], linear[1, 2], translation[1]],
                [linear[2, 0], linear[2, 1], linear[2, 2], translation[2]],
                [.zero, .zero, .zero, 1],
            ]
        )
    }

    /// The upper left 3 × 3: the linear part of a map of space, which moves directions.
    @inlinable
    public var linear: Matrix<3, 3, Scalar> {
        Matrix<3, 3, Scalar>(rows: InlineArray { row in InlineArray { column in self[row, column] } })
    }

    /// The first three entries of the last column: where a map of space takes the origin.
    @inlinable
    public var translation: Vector<3, Scalar> {
        Vector([self[0, 3], self[1, 3], self[2, 3]])
    }

    @inlinable
    public static func translation(_ offset: Vector<3, Scalar>) -> Self {
        Self(linear: .identity, translation: offset)
    }

    @inlinable
    public static func scale(_ factors: Vector<3, Scalar>) -> Self {
        Self(
            linear: Matrix<3, 3, Scalar>(
                rows: [
                    [factors[0], .zero, .zero],
                    [.zero, factors[1], .zero],
                    [.zero, .zero, factors[2]],
                ]
            )
        )
    }

    @inlinable
    public static func scale(_ factor: Scalar) -> Self {
        scale(Vector([factor, factor, factor]))
    }
}
