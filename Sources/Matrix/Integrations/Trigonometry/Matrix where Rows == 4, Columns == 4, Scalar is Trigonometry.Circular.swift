#if Trigonometry
    public import Trigonometry

    extension Matrix where Rows == 4, Columns == 4, Scalar: Trigonometry.Circular {

        @inlinable
        public static func rotation(aboutX angle: Scalar) -> Self {
            let cosine = Scalar.cos(angle)
            let sine = Scalar.sin(angle)
            return Self(linear: Matrix<3, 3, Scalar>(rows: [[1, 0, 0], [0, cosine, -sine], [0, sine, cosine]]))
        }

        @inlinable
        public static func rotation(aboutY angle: Scalar) -> Self {
            let cosine = Scalar.cos(angle)
            let sine = Scalar.sin(angle)
            return Self(linear: Matrix<3, 3, Scalar>(rows: [[cosine, 0, sine], [0, 1, 0], [-sine, 0, cosine]]))
        }

        @inlinable
        public static func rotation(aboutZ angle: Scalar) -> Self {
            let cosine = Scalar.cos(angle)
            let sine = Scalar.sin(angle)
            return Self(linear: Matrix<3, 3, Scalar>(rows: [[cosine, -sine, 0], [sine, cosine, 0], [0, 0, 1]]))
        }
    }
#endif
