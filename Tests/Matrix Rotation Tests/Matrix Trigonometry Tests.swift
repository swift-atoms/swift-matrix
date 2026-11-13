#if Rotation && Trigonometry
    import Foundation
    import Matrix
    import Testing

    extension `Matrix Rotation Tests` {
        @Suite struct `Turns by an angle need only circular trigonometry` {
            static let angles = [0.0, 0.3, Double.pi / 2, -2.1, Double.pi]

            @Test(arguments: angles)
            func `A plane turn moves x toward y`(angle: Double) {
                let turn = Matrix<2, 2, Double>.rotation(angle)
                #expect(turn == Matrix(rows: [[Foundation.cos(angle), -Foundation.sin(angle)], [Foundation.sin(angle), Foundation.cos(angle)]]))
                let plane = try? Rotation<2, Double>.Plane(first: .primary, second: .secondary, angle: Radian(_unchecked: angle))
                if let plane { #expect(Matrix(Rotation(plane)) == turn) }
            }

            @Test(arguments: angles)
            func `A plane turn about a point keeps that point`(angle: Double) {
                let center = Vector(x: 640.0, y: 360.0)
                let map = Matrix<2, 3, Double>.rotation(angle, about: center)
                let kept = map.applied(to: center)
                #expect(abs(kept[0] - 640) < 1e-9 && abs(kept[1] - 360) < 1e-9)
                #expect(map.linear == .rotation(angle))
                #expect(Matrix<2, 3, Double>.rotation(angle) == Matrix(linear: .rotation(angle)))
            }

            @Test(arguments: angles)
            func `A turn about an axis of space is the rotation of the plane of the other two`(angle: Double) throws {
                let radian = Radian(_unchecked: angle)
                let planes = [
                    try Rotation<3, Double>.Plane(first: .init(1), second: .init(2), angle: radian),
                    try Rotation<3, Double>.Plane(first: .init(2), second: .init(0), angle: radian),
                    try Rotation<3, Double>.Plane(first: .init(0), second: .init(1), angle: radian),
                ]
                let turns = [
                    Matrix<4, 4, Double>.rotation(aboutX: angle),
                    .rotation(aboutY: angle),
                    .rotation(aboutZ: angle),
                ]
                for (plane, turn) in zip(planes, turns) {
                    let expected = Matrix<4, 4, Double>(linear: Matrix(Rotation(plane)))
                    (0..<4).forEach { row in
                        (0..<4).forEach { column in #expect(abs(turn[row, column] - expected[row, column]) < 1e-15) }
                    }
                }
                #expect(Matrix<4, 4, Double>.rotation(aboutX: 0) == .identity)
            }
        }
    }
#endif
