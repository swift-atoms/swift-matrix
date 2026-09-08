import Vector

extension Matrix: Swift.Hashable where Scalar: Swift.Hashable {
    public func hash(into hasher: inout Hasher) {
        for row in 0..<Rows {
            for column in 0..<Columns { hasher.combine(self[row, column]) }
        }
    }
}
