import Matrix
import Testing

@Suite struct MathematicalMatrixTests {
    @Test func rectangularProductAndApplicationAgree() {
        let a = Matrix<2, 3, Int>(rows: [[1, 2, 3], [4, 5, 6]])
        let b = Matrix<3, 2, Int>(rows: [[7, 8], [9, 10], [11, 12]])
        let product = a.multiplied(by: b)
        #expect(product == Matrix<2, 2, Int>(rows: [[58, 64], [139, 154]]))
        let vector = Vector<2, Int>([2, 3])
        #expect(product.applied(to: vector) == a.applied(to: b.applied(to: vector)))
        #expect(a.transposed.transposed == a)
    }
    @Test func zeroInnerDimensionProducesZero() {
        let left = Matrix<2, 0, Int>(repeating: 99)
        let right = Matrix<0, 3, Int>(repeating: 99)
        #expect(left.multiplied(by: right) == Matrix<2, 3, Int>.zero)
        #expect(left.transposed.transposed == left)
    }
}
