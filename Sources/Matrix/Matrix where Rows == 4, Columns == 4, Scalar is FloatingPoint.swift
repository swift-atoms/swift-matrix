extension Matrix where Rows == 4, Columns == 4, Scalar: FloatingPoint {

    /// The view transform of an eye at `eye` looking at `target`: a turn and a translation that take the
    /// eye to the origin, the ray from the eye through the target onto the negative z axis, and `up` into
    /// the half of space with positive y. It throws `Matrix.Error.singular` when the target is the eye or
    /// `up` lies along the line of sight, because no turn is then determined.
    @inlinable
    public static func looking(
        at target: Vector<3, Scalar>,
        from eye: Vector<3, Scalar>,
        up: Vector<3, Scalar>
    ) throws(Error) -> Self {
        func cross(_ a: Vector<3, Scalar>, _ b: Vector<3, Scalar>) -> Vector<3, Scalar> {
            Vector([a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]])
        }
        func normalized(_ vector: Vector<3, Scalar>) throws(Error) -> Vector<3, Scalar> {
            let length = vector.dot(vector).squareRoot()
            guard length > 0, length.isFinite else { throw .singular }
            return vector.scaled(by: 1 / length)
        }
        let forward = try normalized(target - eye)
        let right = try normalized(cross(forward, up))
        let above = cross(right, forward)
        let turn = Matrix<3, 3, Scalar>(
            rows: [
                [right[0], right[1], right[2]],
                [above[0], above[1], above[2]],
                [-forward[0], -forward[1], -forward[2]],
            ]
        )
        let moved = turn.applied(to: eye)
        return Self(linear: turn, translation: Vector([-moved[0], -moved[1], -moved[2]]))
    }
}
