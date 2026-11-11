#if Projection
    public import Projection

    extension Matrix where Rows == 4, Columns == 4, Scalar: BinaryFloatingPoint {

        @inlinable
        public init(_ projection: Projection<Scalar>) {
            self.init(rows: projection.coefficients)
        }
    }
#endif
