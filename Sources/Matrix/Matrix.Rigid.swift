extension Matrix where Rows == 4, Columns == 4, Scalar: FloatingPoint {

    /// A rigid motion of space: a rotation, then a translation, so a point x goes to
    /// `rotation · x + translation`. It keeps lengths, angles and handedness. As a 4 × 4 matrix it is
    /// `Matrix(linear: rotation, translation: translation)`, and a 4 × 4 matrix is one when its last row
    /// is (0, 0, 0, 1) and its linear part is a rotation to within a tolerance.
    public struct Rigid {
        /// The turn, applied first: orthonormal with determinant +1, to within the tolerance it was
        /// recognised with.
        public let rotation: Matrix<3, 3, Scalar>

        /// Where the motion takes the origin.
        public let translation: Vector<3, Scalar>

        @usableFromInline
        init(unchecked rotation: Matrix<3, 3, Scalar>, translation: Vector<3, Scalar>) {
            self.rotation = rotation
            self.translation = translation
        }

        /// A rotation and a translation as a rigid motion, or nil unless the rotation is one to within
        /// `tolerance`, `isRotation(within:)`, and the translation is finite.
        @inlinable
        public init?(rotation: Matrix<3, 3, Scalar>, translation: Vector<3, Scalar>, within tolerance: Scalar) {
            guard rotation.isRotation(within: tolerance), (0..<3).allSatisfy({ translation[$0].isFinite }) else { return nil }
            self.init(unchecked: rotation, translation: translation)
        }

        /// A 4 × 4 matrix taken apart into its rotation and translation, or nil unless its last row is
        /// exactly (0, 0, 0, 1) and `init(rotation:translation:within:)` accepts its parts. The parts are the
        /// matrix's own entries, so `matrix` of the result is the matrix exactly.
        @inlinable
        public init?(_ matrix: Matrix<4, 4, Scalar>, within tolerance: Scalar) {
            guard matrix[3, 0] == 0, matrix[3, 1] == 0, matrix[3, 2] == 0, matrix[3, 3] == 1 else { return nil }
            self.init(rotation: matrix.linear, translation: matrix.translation, within: tolerance)
        }
    }
}

extension Matrix.Rigid: Swift::Equatable {}
extension Matrix.Rigid: Swift::Hashable where Scalar: Swift::Hashable {}
extension Matrix.Rigid: Swift::Sendable where Scalar: Swift::Sendable {}

extension Matrix.Rigid {

    /// The motion that moves nothing.
    @inlinable
    public static var identity: Self { Self(unchecked: .identity, translation: .zero) }

    /// The motion as a 4 × 4 matrix acting on (x, y, z, 1): the rotation over the translation.
    @inlinable
    public var matrix: Matrix<4, 4, Scalar> { Matrix<4, 4, Scalar>(linear: rotation, translation: translation) }

    /// A point moved: `rotation · point + translation`.
    @inlinable
    public func applied(to point: Vector<3, Scalar>) -> Vector<3, Scalar> {
        rotation.applied(to: point) + translation
    }

    /// The motion that undoes this one, by the transpose: the rotation transposed and the translation
    /// `−rotationᵀ · translation`, so `followed(by: inverse)` is the identity up to rounding.
    @inlinable
    public var inverse: Self {
        let turn = rotation.transposed
        let moved = turn.applied(to: translation)
        return Self(unchecked: turn, translation: .zero - moved)
    }

    /// This motion, then another: the rotation `other.rotation · rotation` and the translation
    /// `other.rotation · translation + other.translation`, so its `matrix` is
    /// `other.matrix.multiplied(by: matrix)` up to rounding.
    @inlinable
    public func followed(by other: Self) -> Self {
        Self(
            unchecked: other.rotation.multiplied(by: rotation),
            translation: other.rotation.applied(to: translation) + other.translation
        )
    }
}
