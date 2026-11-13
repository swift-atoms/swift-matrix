#if Trigonometry
    public import Trigonometry

    extension Matrix where Rows == 2, Columns == 3, Scalar: Trigonometry.Circular {

        @inlinable
        public static func rotation(_ angle: Scalar, about center: Vector<2, Scalar> = .zero) -> Self {
            Self(linear: .rotation(angle), about: center)
        }
    }

    extension Matrix where Rows == 2, Columns == 3, Scalar: Trigonometry.Circular {

        /// The affine map a share of the way from this one to `other`, mixed by parts so that a turn stays
        /// a turn. Each linear part is read as a turn after a stretch, `rotation(angle) · stretch`, where the
        /// angle is that of the first column and the stretch is upper triangular. The angle moves the
        /// shorter way round, and the stretch's entries and the translation move in a straight line.
        @inlinable
        public func mixed(to other: Self, at share: Scalar) -> Self {
            let angles = (Scalar.atan2(self[1, 0], self[0, 0]), Scalar.atan2(other[1, 0], other[0, 0]))
            let stretches = (
                Matrix<2, 2, Scalar>.rotation(-angles.0).multiplied(by: linear),
                Matrix<2, 2, Scalar>.rotation(-angles.1).multiplied(by: other.linear)
            )
            let turn = (angles.1 - angles.0).remainder(dividingBy: 2 * Scalar.pi)
            let stretch = Matrix<2, 2, Scalar>(
                rows: InlineArray { row in
                    InlineArray { column in
                        stretches.0[row, column] + (stretches.1[row, column] - stretches.0[row, column]) * share
                    }
                }
            )
            return Self(
                linear: Matrix<2, 2, Scalar>.rotation(angles.0 + turn * share).multiplied(by: stretch),
                translation: translation + (other.translation - translation).scaled(by: share)
            )
        }
    }
#endif
