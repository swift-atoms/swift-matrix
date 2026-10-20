#if Scale
    @_exported public import Scale

    extension Matrix where Rows == Columns, Scalar: AdditiveArithmetic {

        public init(_ scale: Scale<Rows, Scalar>) {
            self.init(repeating: .zero)
            for index in 0..<Rows { self[index, index] = scale[index] }
        }
    }

    extension Scale where Scalar: AdditiveArithmetic {
        public var matrix: Matrix<N, N, Scalar> { Matrix(self) }
    }
#endif
