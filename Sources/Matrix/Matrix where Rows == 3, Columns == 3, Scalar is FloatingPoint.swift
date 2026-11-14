extension Matrix where Rows == 3, Columns == 3, Scalar: FloatingPoint {

    /// The affine map as a projective map of the plane: its two rows over the row (0, 0, 1).
    @inlinable
    public init(_ affine: Matrix<2, 3, Scalar>) {
        self.init(
            rows: [
                [affine[0, 0], affine[0, 1], affine[0, 2]],
                [affine[1, 0], affine[1, 1], affine[1, 2]],
                [.zero, .zero, 1],
            ]
        )
    }

    /// The determinant, by the first row's cofactors.
    @inlinable
    public var determinant: Scalar {
        self[0, 0] * (self[1, 1] * self[2, 2] - self[1, 2] * self[2, 1])
            - self[0, 1] * (self[1, 0] * self[2, 2] - self[1, 2] * self[2, 0])
            + self[0, 2] * (self[1, 0] * self[2, 1] - self[1, 1] * self[2, 0])
    }

    /// The inverse: each entry of the adjugate divided by the determinant. It throws `Matrix.Error.singular`
    /// exactly when the determinant is zero.
    @inlinable
    public func inverted() throws(Error) -> Self {
        let determinant = self.determinant
        guard determinant != 0 else { throw .singular }
        func minor(_ row: Int, _ column: Int) -> Scalar {
            let rows = (0..<3).filter { $0 != row }
            let columns = (0..<3).filter { $0 != column }
            return self[rows[0], columns[0]] * self[rows[1], columns[1]] - self[rows[0], columns[1]] * self[rows[1], columns[0]]
        }
        var result = Self(repeating: .zero)
        (0..<3).forEach { row in
            (0..<3).forEach { column in
                let cofactor = minor(column, row)
                result[row, column] = ((row + column) % 2 == 0 ? cofactor : -cofactor) / determinant
            }
        }
        return result
    }

    /// Whether this matrix is a rotation of space to within a tolerance: every entry of `self · transposed`
    /// is within `tolerance` of the identity's, so the rows are orthonormal up to it, and the determinant is
    /// positive, so it is +1 up to it and the matrix turns without reflecting. A matrix with an entry that is
    /// not a number, or a tolerance that is negative or not a number, is not a rotation.
    @inlinable
    public func isRotation(within tolerance: Scalar) -> Bool {
        let product = multiplied(by: transposed)
        let orthonormal = (0..<9).allSatisfy { index in
            let (row, column) = (index / 3, index % 3)
            return abs(product[row, column] - (row == column ? 1 : 0)) <= tolerance
        }
        return orthonormal && determinant > 0
    }

    /// A point of the plane through this matrix as a projective map: the column (x, y, 1) multiplied, and its
    /// first two entries divided by the third. For the lift of an affine map, whose last row is (0, 0, 1), it
    /// is the affine map's `applied(to:)` exactly. A point the map sends to infinity, where the third entry is
    /// zero, comes back with entries that are not finite.
    @inlinable
    public func projected(_ point: Vector<2, Scalar>) -> Vector<2, Scalar> {
        let moved = applied(to: Vector<3, Scalar>([point[0], point[1], 1]))
        return Vector([moved[0] / moved[2], moved[1] / moved[2]])
    }
}

extension Matrix where Rows == 3, Columns == 3, Scalar: FloatingPoint {

    /// The projective map that takes each of four points exactly onto its target: the map of the plane that
    /// keeps straight lines straight and is fixed by four points, no three of them on one line, and their
    /// images. Four corners of a quadrilateral fitted onto another are a picture of a card seen in perspective.
    ///
    /// It is the map that takes the unit square's corners (0, 0), (1, 0), (1, 1), (0, 1) onto the targets,
    /// after the inverse of the one that takes them onto the sources, each by Heckbert's closed form. When the
    /// targets are a parallelogram of the sources' affine image the last row is (0, 0, 1) up to rounding, and
    /// the map is affine. It throws `Matrix.Error.singular` when three of the sources, or of the targets, lie on
    /// one line, as no such map then exists.
    @inlinable
    public init(fitting sources: InlineArray<4, Vector<2, Scalar>>, onto targets: InlineArray<4, Vector<2, Scalar>>) throws(Error) {
        let from = try Self.square(onto: sources)
        let to = try Self.square(onto: targets)
        self = to.multiplied(by: try from.inverted())
    }

    /// The projective map that takes the unit square's corners, in the order (0, 0), (1, 0), (1, 1), (0, 1),
    /// onto four points, by Heckbert's closed form.
    @usableFromInline
    static func square(onto corners: InlineArray<4, Vector<2, Scalar>>) throws(Error) -> Self {
        let (x0, y0) = (corners[0][0], corners[0][1])
        let (x1, y1) = (corners[1][0], corners[1][1])
        let (x2, y2) = (corners[2][0], corners[2][1])
        let (x3, y3) = (corners[3][0], corners[3][1])
        let (dx1, dy1) = (x1 - x2, y1 - y2)
        let (dx2, dy2) = (x3 - x2, y3 - y2)
        let (dx3, dy3) = (x0 - x1 + x2 - x3, y0 - y1 + y2 - y3)
        let determinant = dx1 * dy2 - dx2 * dy1
        guard determinant != 0 else { throw .singular }
        let g = (dx3 * dy2 - dx2 * dy3) / determinant
        let h = (dx1 * dy3 - dx3 * dy1) / determinant
        let map = Self(
            rows: [
                [x1 - x0 + g * x1, x3 - x0 + h * x3, x0],
                [y1 - y0 + g * y1, y3 - y0 + h * y3, y0],
                [g, h, 1],
            ]
        )
        let check = map.determinant
        guard check != 0, check.isFinite else { throw .singular }
        return map
    }
}
