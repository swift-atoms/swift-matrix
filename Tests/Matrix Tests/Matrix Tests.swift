import Matrix
import Testing

enum `Matrix Tests` {}

extension `Matrix Tests` {
    @Suite struct `Matrix products preserve shape and scalar evaluation order` {
        @Test func `Matrix reductions preserve scalar rounding order`() {
            let values = Matrix<1, 3, Double>(rows: [[1e16, 1, -1e16]])
            let factors = Matrix<3, 1, Double>(repeating: 1)
            #expect(values.multiplied(by: factors)[0, 0] == 0)
            #expect(values.applied(to: .init(repeating: 1))[0] == 0)
        }

        @Test func `Zero outer dimensions preserve product shape`() {
            let noRows = Matrix<0, 3, Int>(repeating: 7)
            let right = Matrix<3, 2, Int>(repeating: 5)
            #expect(noRows.multiplied(by: right) == Matrix<0, 2, Int>.zero)
            #expect(noRows.applied(to: .init(repeating: 1)) == Vector<0, Int>.zero)
            let noColumns = Matrix<3, 0, Int>(repeating: 7)
            #expect(right.transposed.multiplied(by: noColumns) == Matrix<2, 0, Int>.zero)
            #expect(noColumns.applied(to: .zero) == Vector<3, Int>.zero)
        }

        @Test func `Rectangular product and application agree`() {
            let a = Matrix<2, 3, Int>(rows: [[1, 2, 3], [4, 5, 6]])
            let b = Matrix<3, 2, Int>(rows: [[7, 8], [9, 10], [11, 12]])
            let product = a.multiplied(by: b)
            #expect(product == Matrix<2, 2, Int>(rows: [[58, 64], [139, 154]]))
            let vector = Vector<2, Int>([2, 3])
            #expect(product.applied(to: vector) == a.applied(to: b.applied(to: vector)))
            #expect(a.transposed.transposed == a)
        }
        @Test func `Zero inner dimension produces zero`() {
            let left = Matrix<2, 0, Int>(repeating: 99)
            let right = Matrix<0, 3, Int>(repeating: 99)
            #expect(left.multiplied(by: right) == Matrix<2, 3, Int>.zero)
            #expect(left.transposed.transposed == left)
        }
    }
}
