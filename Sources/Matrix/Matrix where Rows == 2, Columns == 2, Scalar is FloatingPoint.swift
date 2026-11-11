extension Matrix where Rows == 2, Columns == 2, Scalar: FloatingPoint {

    @inlinable
    public var determinant: Scalar {
        self[0, 0] * self[1, 1] - self[0, 1] * self[1, 0]
    }

    @inlinable
    public func inverted() throws(Error) -> Self {
        let determinant = self.determinant
        guard determinant != 0 else { throw .singular }
        return Self(
            rows: [
                [self[1, 1] / determinant, -self[0, 1] / determinant],
                [-self[1, 0] / determinant, self[0, 0] / determinant],
            ]
        )
    }
}
