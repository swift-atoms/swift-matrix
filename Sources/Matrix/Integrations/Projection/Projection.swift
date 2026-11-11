#if Projection
    public import Projection

    extension Projection {
        @inlinable
        public var matrix: Matrix<4, 4, Scalar> { Matrix(self) }
    }
#endif
