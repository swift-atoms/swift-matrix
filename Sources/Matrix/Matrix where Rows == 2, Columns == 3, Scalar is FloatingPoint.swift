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

extension Matrix where Rows == 2, Columns == 3, Scalar: FloatingPoint {

    /// The affine map nearest to taking each source point to its target: the one that minimises the sum
    /// of the squared distances from each moved source to its target, the least-squares fit over the
    /// correspondences. Three points not on one line fit exactly, and so do the four corners of a square
    /// or rectangle taken to the corners of a parallelogram.
    ///
    /// Its linear part is the targets' covariance with the sources times the inverse of the sources' own
    /// scatter, both about their means, and it takes the sources' mean to the targets' mean. It throws
    /// `Matrix.Error.singular` when that scatter has a zero determinant, as when the sources all lie on
    /// one line or there are none.
    @inlinable
    public init<let Count: Int>(
        fitting sources: InlineArray<Count, Vector<2, Scalar>>,
        onto targets: InlineArray<Count, Vector<2, Scalar>>
    ) throws(Error) {
        var sourceSum: Vector<2, Scalar> = .zero
        var targetSum: Vector<2, Scalar> = .zero
        sources.indices.forEach { index in
            sourceSum = sourceSum + sources[index]
            targetSum = targetSum + targets[index]
        }
        let count = Scalar(Count)
        let sourceMean = Vector<2, Scalar>([sourceSum[0] / count, sourceSum[1] / count])
        let targetMean = Vector<2, Scalar>([targetSum[0] / count, targetSum[1] / count])
        var scatter: Matrix<2, 2, Scalar> = .zero
        var covariance: Matrix<2, 2, Scalar> = .zero
        sources.indices.forEach { index in
            let source = sources[index] - sourceMean
            let target = targets[index] - targetMean
            (0..<2).forEach { row in
                (0..<2).forEach { column in
                    scatter[row, column] += source[row] * source[column]
                    covariance[row, column] += target[row] * source[column]
                }
            }
        }
        let inverse: Matrix<2, 2, Scalar>
        do throws(Matrix<2, 2, Scalar>.Error) {
            inverse = try scatter.inverted()
        } catch {
            throw .singular
        }
        let linear = covariance.multiplied(by: inverse)
        let moved = linear.applied(to: sourceMean)
        self.init(linear: linear, translation: targetMean - moved)
    }
}
