#if Shear
    @_exported public import Shear

    extension Matrix where Rows == Columns, Scalar: BinaryFloatingPoint {

        public init(_ shear: Shear<Rows, Scalar>) {
            self.init(repeating: 0)
            for index in 0..<Rows { self[index, index] = 1 }
            self[shear.target.underlying, shear.source.underlying] = shear.factor.value
        }
    }

    extension Shear {

        public var matrix: Matrix<N, N, Scalar> { Matrix(self) }
    }
#endif
