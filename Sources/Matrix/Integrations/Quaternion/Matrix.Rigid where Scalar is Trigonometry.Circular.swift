#if Quaternion
    public import Quaternion

    extension Matrix.Rigid where Scalar: Trigonometry.Circular {

        /// The motion a share of the way to another: the rotation turns along the shorter arc at an even
        /// angular rate, by `Quaternion.interpolated(to:at:)` of the two rotations' quaternions, and the
        /// translation goes in a straight line, by `Vector.interpolated(to:at:)`, so the origin's image moves
        /// straight and the motion stays rigid. A share of 0 gives this motion and a share of 1 the other
        /// exactly. Between rotations a half turn apart the arc about the relative rotation's axis is taken.
        @inlinable
        public func interpolated(to other: Self, at share: Scalar) -> Self {
            if share == 0 { return self }
            if share == 1 { return other }
            let turn = Quaternion(rotation).interpolated(to: Quaternion(other.rotation), at: share)
            return Self(unchecked: Matrix<3, 3, Scalar>(turn), translation: translation.interpolated(to: other.translation, at: share))
        }
    }
#endif
