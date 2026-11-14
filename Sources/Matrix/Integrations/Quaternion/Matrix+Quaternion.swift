#if Quaternion
    public import Quaternion

    extension Matrix where Rows == 3, Columns == 3, Scalar: FloatingPoint {

        /// The rotation matrix of a unit quaternion, acting on column vectors.
        ///
        /// The entries are those of the unit formula, so a quaternion that is not of unit length
        /// gives a matrix that is not a rotation; normalise it first.
        @inlinable
        public init(_ quaternion: Quaternion<Scalar>) {
            let (w, x, y, z) = (quaternion.w, quaternion.x, quaternion.y, quaternion.z)
            self.init(rows: [
                [1 - 2 * (y * y + z * z), 2 * (x * y - w * z), 2 * (x * z + w * y)],
                [2 * (x * y + w * z), 1 - 2 * (x * x + z * z), 2 * (y * z - w * x)],
                [2 * (x * z - w * y), 2 * (y * z + w * x), 1 - 2 * (x * x + y * y)],
            ])
        }
    }

    extension Quaternion where Scalar: FloatingPoint {

        /// The unit quaternion of a rotation matrix, by Shepperd's method, with a non-negative
        /// real part.
        ///
        /// Shepperd's method divides by the largest of the four candidate parts, so it is accurate
        /// for every rotation, a half turn included. For a matrix that is not a rotation the
        /// result has no meaning; check orthonormality and a positive determinant first where the
        /// input is not known to be a rotation.
        @inlinable
        public init(_ matrix: Matrix<3, 3, Scalar>) {
            let m = matrix
            let trace = m[0, 0] + m[1, 1] + m[2, 2]
            if trace > 0 {
                let s = (trace + 1).squareRoot() * 2
                self.init(w: s / 4, x: (m[2, 1] - m[1, 2]) / s, y: (m[0, 2] - m[2, 0]) / s, z: (m[1, 0] - m[0, 1]) / s)
            } else if m[0, 0] > m[1, 1], m[0, 0] > m[2, 2] {
                let s = (1 + m[0, 0] - m[1, 1] - m[2, 2]).squareRoot() * 2
                self.init(w: (m[2, 1] - m[1, 2]) / s, x: s / 4, y: (m[0, 1] + m[1, 0]) / s, z: (m[0, 2] + m[2, 0]) / s)
            } else if m[1, 1] > m[2, 2] {
                let s = (1 + m[1, 1] - m[0, 0] - m[2, 2]).squareRoot() * 2
                self.init(w: (m[0, 2] - m[2, 0]) / s, x: (m[0, 1] + m[1, 0]) / s, y: s / 4, z: (m[1, 2] + m[2, 1]) / s)
            } else {
                let s = (1 + m[2, 2] - m[0, 0] - m[1, 1]).squareRoot() * 2
                self.init(w: (m[1, 0] - m[0, 1]) / s, x: (m[0, 2] + m[2, 0]) / s, y: (m[1, 2] + m[2, 1]) / s, z: s / 4)
            }
            if w < 0 { self = -self }
        }

        /// The rotation matrix of this unit quaternion.
        @inlinable
        public var matrix: Matrix<3, 3, Scalar> { Matrix(self) }
    }
#endif
