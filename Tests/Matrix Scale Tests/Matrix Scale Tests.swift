#if Scale
    import Matrix
    import Testing

    enum `Matrix Scale Tests` {}

    extension `Matrix Scale Tests` {
        @Suite struct `Scale matrix representation` {
            @Test func `Integer factors form a diagonal matrix and scale each coordinate`() {
                let scale = Scale<3, Int>(x: 2, y: -3, z: 0)
                let matrix = Matrix(scale)
                #expect(matrix.applied(to: Vector(x: 4, y: 5, z: 6)) == Vector(x: 8, y: -15, z: 0))
                (0..<3).forEach { row in
                    (0..<3).forEach { column in #expect(matrix[row, column] == (row == column ? scale[row] : 0)) }
                }
                #expect(scale.matrix == matrix)
            }

            @Test func `Empty and scalar scales retain exact dimensions`() {
                let empty = Scale<0, Int>(InlineArray(repeating: 0))
                #expect(Matrix(empty) == Matrix<0, 0, Int>(repeating: 7))
                #expect(Matrix(Scale<1, Double>(2.5))[0, 0] == 2.5)
            }

            @Test func `Componentwise scale composition matches matrix multiplication`() {
                let first = Scale<2, Double>(x: 2, y: -0.5)
                let second = Scale<2, Double>(x: 3, y: 4)
                #expect(Matrix(first.concatenating(second)) == Matrix(second).multiplied(by: Matrix(first)))
                let identity = Matrix(first).multiplied(by: Matrix(first.inverted))
                #expect(identity[0, 0] == 1 && identity[1, 1] == 1)
                #expect(identity[0, 1] == 0 && identity[1, 0] == 0)
            }

            @Test func `Conversion preserves nonfinite factors without claiming validity`() {
                let matrix = Matrix(Scale<2, Double>(x: .infinity, y: .nan))
                #expect(matrix[0, 0] == .infinity)
                #expect(matrix[1, 1].isNaN)
                #expect(matrix[0, 1] == 0 && matrix[1, 0] == 0)
            }

            @Test func `Matrix conversion snapshots independently mutable scale storage`() {
                var scale = Scale<2, Float>(x: 2, y: 3)
                let matrix = scale.matrix
                scale.x = 9
                #expect(matrix[0, 0] == 2)
                #expect(scale.matrix[0, 0] == 9)
            }
        }
    }
#endif
