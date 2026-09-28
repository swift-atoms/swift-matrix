#if Rotation && Trigonometry
@_exported public import Rotation
@_exported public import Trigonometry

extension Matrix where Rows == Columns, Scalar: BinaryFloatingPoint & Trigonometry.Circular {

    public init(_ rotation: Rotation<Rows, Scalar>) {
        self.init(repeating: 0)
        for index in 0..<Rows { self[index, index] = 1 }
        for plane in rotation.planes {
            let first = plane.first.underlying
            let second = plane.second.underlying
            let sine = Scalar.sin(plane.angle.underlying)
            let cosine = Scalar.cos(plane.angle.underlying)

            for column in 0..<Columns {
                let a = self[first, column]
                let b = self[second, column]
                self[first, column] = cosine * a - sine * b
                self[second, column] = sine * a + cosine * b
            }
        }
    }
}

extension Rotation where Scalar: Trigonometry.Circular {
    public var matrix: Matrix<N, N, Scalar> { Matrix(self) }
}
#endif
