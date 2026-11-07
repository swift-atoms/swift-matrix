import Vector

extension Matrix: Swift::Hashable where Scalar: Swift::Hashable {
    public func hash(into hasher: inout Hasher) {
        (0..<Rows).forEach { row in
            for column in 0..<Columns { hasher.combine(self[row, column]) }
        }
    }
}
