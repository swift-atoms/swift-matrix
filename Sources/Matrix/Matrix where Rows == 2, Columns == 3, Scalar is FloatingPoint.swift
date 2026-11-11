extension Matrix where Rows == 2, Columns == 3, Scalar: FloatingPoint {

    @inlinable
    public func inverted() throws(Error) -> Self {
        let inverse: Matrix<2, 2, Scalar>
        do throws(Matrix<2, 2, Scalar>.Error) {
            inverse = try linear.inverted()
        } catch {
            throw .singular
        }
        let moved = inverse.applied(to: translation)
        return Self(linear: inverse, translation: Vector([-moved[0], -moved[1]]))
    }
}
