#if Projection
    import Matrix
    import Testing

    enum `Matrix Projection Tests` {}

    extension `Matrix Projection Tests` {
        @Suite struct `Projection matrix evaluation` {
            private func projections() throws -> [Projection<Double>] {
                var result: [Projection<Double>] = []
                for kind in Projection<Double>.Kind.allCases {
                    for depth in Projection<Double>.Depth.allCases {
                        result.append(
                            try Projection(kind, left: -2, right: 6, bottom: -1, top: 3, near: 0.5, far: 40, depth: depth)
                        )
                    }
                }
                result.append(
                    try Projection(
                        .perspective,
                        left: -1,
                        right: 1,
                        bottom: -1,
                        top: 1,
                        near: 1,
                        far: .infinity,
                        depth: .unit
                    )
                )
                return result
            }

            @Test func `The matrix holds the projection's coefficients row by row`() throws {
                for projection in try projections() {
                    let matrix = Matrix(projection)
                    let rows = projection.coefficients
                    (0..<4).forEach { row in
                        (0..<4).forEach { column in #expect(matrix[row, column] == rows[row][column]) }
                    }
                    #expect(projection.matrix == matrix)
                }
            }

            @Test func `Applying the matrix to a homogeneous point gives its clip coordinates exactly`() throws {
                for projection in try projections() {
                    for point in [Point<3, Double>(x: 0.75, y: -1.5, z: -9), Point(x: -4, y: 2, z: 3)] {
                        let homogeneous = Vector<4, Double>([point.x, point.y, point.z, 1])
                        #expect(projection.matrix.applied(to: homogeneous) == projection.clip(point))
                    }
                }
            }

            @Test func `Perspective matrices end in the row that copies negated depth and orthographic ones in the affine row`() throws {
                for projection in try projections() {
                    let matrix = projection.matrix
                    let last = (0..<4).map { matrix[3, $0] }
                    #expect(last == (projection.kind == .perspective ? [0, 0, -1, 0] : [0, 0, 0, 1]))
                }
            }

            @Test func `A projection composes with a transform by an ordinary product`() throws {
                let projection = try projections()[0]
                var view = Matrix<4, 4, Double>(repeating: 0)
                (0..<4).forEach { view[$0, $0] = 1 }
                view[0, 3] = 2
                view[2, 3] = -10
                let combined = projection.matrix.multiplied(by: view)
                let world = Vector<4, Double>([1, 1, 1, 1])
                let clip = combined.applied(to: world)
                let expected = projection.clip(Point(x: 3, y: 1, z: -9))
                (0..<4).forEach { #expect(abs(clip[$0] - expected[$0]) < 1e-12) }
            }
        }
    }
#endif
