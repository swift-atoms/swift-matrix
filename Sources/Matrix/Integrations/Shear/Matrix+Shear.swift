#if Shear
    public import Shear

    extension Matrix where Rows == Columns, Scalar: BinaryFloatingPoint {

        @inlinable
        public init(_ shear: Shear<Rows, Scalar>) {
            self.init(repeating: 0)
            (0..<Rows).forEach { index in self[index, index] = 1 }
            self[shear.target.underlying, shear.source.underlying] = shear.factor.value
        }
    }

    extension Shear {

        @inlinable
        public var matrix: Matrix<N, N, Scalar> { Matrix(self) }
    }
#endif
