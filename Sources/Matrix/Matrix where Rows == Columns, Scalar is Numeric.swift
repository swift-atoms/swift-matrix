extension Matrix where Rows == Columns, Scalar: Numeric {

    @inlinable
    public static var identity: Self {
        var result = Self(repeating: .zero)
        (0..<Rows).forEach { index in result[index, index] = 1 }
        return result
    }
}
