#if Trigonometry
    public import Trigonometry

    extension Matrix where Rows == 2, Columns == 3, Scalar: Trigonometry.Circular {

        @inlinable
        public static func rotation(_ angle: Scalar, about center: Vector<2, Scalar> = .zero) -> Self {
            Self(linear: .rotation(angle), about: center)
        }
    }
#endif
