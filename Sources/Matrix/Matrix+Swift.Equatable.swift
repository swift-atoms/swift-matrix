public import Vector

extension Matrix: Swift.Equatable where Scalar: Swift.Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        for row in 0..<Rows {
            for column in 0..<Columns where lhs[row, column] != rhs[row, column] { return false }
        }
        return true
    }
}
