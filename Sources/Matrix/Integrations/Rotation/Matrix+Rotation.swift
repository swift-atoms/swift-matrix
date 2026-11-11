#if Rotation && Trigonometry
    @_exported public import Rotation
    @_exported public import Trigonometry

    extension Matrix where Rows == Columns, Scalar: BinaryFloatingPoint & Trigonometry.Circular {

        @inlinable
        public init(_ rotation: Rotation<Rows, Scalar>) {
            self.init(repeating: 0)
            (0..<Rows).forEach { index in self[index, index] = 1 }
            for plane in rotation.planes {
                let first = plane.first.underlying
                let second = plane.second.underlying
                let sine = Scalar.sin(plane.angle.underlying)
                let cosine = Scalar.cos(plane.angle.underlying)

                (0..<Columns).forEach { column in
                    let a = self[first, column]
                    let b = self[second, column]
                    self[first, column] = cosine * a - sine * b
                    self[second, column] = sine * a + cosine * b
                }
            }
        }
    }

    extension Rotation where Scalar: Trigonometry.Circular {
        @inlinable
        public var matrix: Matrix<N, N, Scalar> { Matrix(self) }
    }
#endif
