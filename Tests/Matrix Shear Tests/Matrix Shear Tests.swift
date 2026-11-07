#if Shear
    import Matrix
    import Testing

enum `Matrix Shear Tests` {}

extension `Matrix Shear Tests` {
        @Suite struct `Shear matrix representation` {
            @Test func `Conversion preserves identity entries and the selected factor`() throws {
                let shear = try Shear<3, Double>(target: .primary, source: .tertiary, factor: Scale(2))
                let matrix = Matrix(shear)
                (0..<3).forEach { row in
                    for column in 0..<3 {
                        let expected = row == column ? 1.0 : (row == 0 && column == 2 ? 2.0 : 0.0)
                        #expect(matrix[row, column] == expected)
                    }
                }
                #expect(shear.matrix == matrix)
            }

            @Test func `Inverse matrices multiply to identity for exact sample values`() throws {
                let shear = try Shear<2, Double>(target: .primary, source: .secondary, factor: Scale(3))
                let product = Matrix(shear).multiplied(by: Matrix(shear.inverse))
                #expect(product[0, 0] == 1 && product[1, 1] == 1)
                #expect(product[0, 1] == 0 && product[1, 0] == 0)
            }
        }
}

extension `Matrix Shear Tests` {
        @Suite struct `Shear matrix boundaries` {
            @Test(arguments: [0.0, -2.0, 0.5, Double.greatestFiniteMagnitude])
            func `Every ordered axis pair maps the source basis to the target`(factor: Double) throws {
                for target in 0..<4 {
                    for source in 0..<4 where source != target {
                        let shear = try Shear<4, Double>(target: Axis(target), source: Axis(source), factor: Scale(factor))
                        let matrix = Matrix(shear)
                        (0..<4).forEach { basis in
                            let unit = Vector<4, Double>(InlineArray { $0 == basis ? 1 : 0 })
                            let moved = matrix.applied(to: unit)
                            for coordinate in 0..<4 {
                                let expected = coordinate == basis ? 1.0 : (basis == source && coordinate == target ? factor : 0.0)
                                #expect(moved[coordinate] == expected)
                            }
                        }
                    }
                }
            }

            @Test func `Conversion is a value snapshot and does not share mutable matrix storage`() throws {
                let shear = try Shear<2, Float>(target: .secondary, source: .primary, factor: Scale(-0.5))
                var matrix = shear.matrix
                matrix[1, 0] = 9
                #expect(shear.matrix[1, 0] == -0.5)
                #expect(matrix[1, 0] == 9)
            }
        }
}

    @Test func `Two different elementary shears compose as matrices and not by adding off diagonal factors`() throws {
        let horizontal = try Shear<2, Double>(target: .primary, source: .secondary, factor: Scale(2))
        let vertical = try Shear<2, Double>(target: .secondary, source: .primary, factor: Scale(3))
        let composition = Matrix(vertical).multiplied(by: Matrix(horizontal))
        let simultaneous = Matrix<2, 2, Double>(rows: [[1, 2], [3, 1]])
        #expect(composition[1, 1] == 7)
        #expect(composition != simultaneous)
        #expect(composition[0, 0] * composition[1, 1] - composition[0, 1] * composition[1, 0] == 1)
        #expect(simultaneous[0, 0] * simultaneous[1, 1] - simultaneous[0, 1] * simultaneous[1, 0] == -5)
    }
#endif
