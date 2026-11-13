extension Matrix where Rows == 2, Columns == 3, Scalar: Numeric {

    @inlinable
    public init(linear: Matrix<2, 2, Scalar>, translation: Vector<2, Scalar> = .zero) {
        self.init(
            rows: [
                [linear[0, 0], linear[0, 1], translation[0]],
                [linear[1, 0], linear[1, 1], translation[1]],
            ]
        )
    }

    @inlinable
    public var linear: Matrix<2, 2, Scalar> {
        Matrix<2, 2, Scalar>(rows: [[self[0, 0], self[0, 1]], [self[1, 0], self[1, 1]]])
    }

    @inlinable
    public var translation: Vector<2, Scalar> {
        Vector([self[0, 2], self[1, 2]])
    }

    @inlinable
    public static var identity: Self {
        Self(linear: .identity)
    }

    @inlinable
    public static func translation(_ offset: Vector<2, Scalar>) -> Self {
        Self(linear: .identity, translation: offset)
    }

    @inlinable
    public init(linear: Matrix<2, 2, Scalar>, about center: Vector<2, Scalar>) {
        let moved = linear.applied(to: center)
        self.init(linear: linear, translation: Vector([center[0] - moved[0], center[1] - moved[1]]))
    }

    @inlinable
    public static func scale(_ factors: Vector<2, Scalar>, about center: Vector<2, Scalar> = .zero) -> Self {
        Self(linear: Matrix<2, 2, Scalar>(rows: [[factors[0], .zero], [.zero, factors[1]]]), about: center)
    }

    @inlinable
    public static func scale(_ factor: Scalar, about center: Vector<2, Scalar> = .zero) -> Self {
        scale(Vector([factor, factor]), about: center)
    }

    @inlinable
    public func applied(to point: Vector<2, Scalar>) -> Vector<2, Scalar> {
        Vector(
            InlineArray { row in
                var result: Scalar = .zero
                result += self[row, 0] * point[0]
                result += self[row, 1] * point[1]
                result += self[row, 2]
                return result
            }
        )
    }

    @inlinable
    public func multiplied(by other: Self) -> Self {
        Self(linear: linear.multiplied(by: other.linear), translation: applied(to: other.translation))
    }
}
