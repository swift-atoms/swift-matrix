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
        func normalized(_ vector: Vector<3, Scalar>) throws(Error) -> Vector<3, Scalar> {
            do throws(Vector<3, Scalar>.Error) { return try vector.normalized } catch { throw .singular }
        }
        let forward = try normalized(target - eye)
        let right = try normalized(forward.cross(up))
        let above = right.cross(forward)
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

extension Matrix where Rows == 4, Columns == 4, Scalar: FloatingPoint {

    /// Whether this matrix is a rigid motion of space to within a tolerance: its last row is exactly
    /// (0, 0, 0, 1), its translation is finite, and its linear part is a rotation, `isRotation(within:)`.
    /// It is exactly when `Rigid(self, within: tolerance)` exists.
    @inlinable
    public func isRigid(within tolerance: Scalar) -> Bool {
        Rigid(self, within: tolerance) != nil
    }
}
