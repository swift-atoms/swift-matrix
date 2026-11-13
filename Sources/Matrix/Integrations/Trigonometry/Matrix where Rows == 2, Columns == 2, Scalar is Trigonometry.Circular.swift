#if Trigonometry
    public import Trigonometry

    extension Matrix where Rows == 2, Columns == 2, Scalar: Trigonometry.Circular {

        @inlinable
        public static func rotation(_ angle: Scalar) -> Self {
            let cosine = Scalar.cos(angle)
            let sine = Scalar.sin(angle)
            return Self(rows: [[cosine, -sine], [sine, cosine]])
        }
    }
#endif
