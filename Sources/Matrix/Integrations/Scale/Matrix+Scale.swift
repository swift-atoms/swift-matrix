#if Scale
    public import Scale

    extension Matrix where Rows == Columns, Scalar: AdditiveArithmetic {

        @inlinable
        public init(_ scale: Scale<Rows, Scalar>) {
            self.init(repeating: .zero)
            (0..<Rows).forEach { index in self[index, index] = scale[index] }
        }
    }

    extension Scale where Scalar: AdditiveArithmetic {
        @inlinable
        public var matrix: Matrix<N, N, Scalar> { Matrix(self) }
    }
#endif
