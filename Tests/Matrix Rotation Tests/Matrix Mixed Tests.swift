#if Rotation && Trigonometry
    import Foundation
    import Matrix
    import Testing

    extension `Matrix Rotation Tests` {
        @Suite struct `Mixing two affine maps keeps a turn a turn` {
            typealias Map = Matrix<2, 3, Double>

            static let maps: [Map] = [
                .identity,
                .rotation(2.5, about: Vector(x: 3.0, y: -1.0)),
                Map(rows: [[2, 3, 7], [0, -4, 1]]),
                Map(rows: [[-1, 0.5, -2], [0.25, 3, 9]]),
            ]

            static func close(_ a: Map, _ b: Map) -> Bool {
                (0..<2).allSatisfy { row in (0..<3).allSatisfy { column in abs(a[row, column] - b[row, column]) < 1e-12 } }
            }

            @Test func `At zero the mix is the map and at one the other`() {
                for start in Self.maps {
                    for end in Self.maps {
                        #expect(Self.close(start.mixed(to: end, at: 0), start))
                        #expect(Self.close(start.mixed(to: end, at: 1), end))
                    }
                }
            }

            @Test(arguments: [0.25, 0.5, 0.75])
            func `A turn mixed from the identity is a turn by that share of the angle`(share: Double) {
                let turn = Map.rotation(2.5, about: Vector(x: 3.0, y: -1.0))
                let mixed = Map.identity.mixed(to: turn, at: share)
                #expect(Self.close(Map(rows: [[mixed[0, 0], mixed[0, 1], 0], [mixed[1, 0], mixed[1, 1], 0]]), .rotation(2.5 * share)))
                let determinant = mixed.linear.determinant
                #expect(abs(determinant - 1) < 1e-12)
            }

            @Test func `The angle goes the shorter way round`() {
                let mixed = Map.rotation(3).mixed(to: .rotation(-3), at: 0.5)
                #expect(Self.close(mixed, .rotation(Double.pi)))
            }

            @Test func `Stretch and translation move in a straight line`() {
                let mixed = Map.scale(Vector(x: 2.0, y: 4.0)).mixed(to: .translation(Vector(x: 10.0, y: -6.0)), at: 0.5)
                #expect(Self.close(mixed, Map(rows: [[1.5, 0, 5], [0, 2.5, -3]])))
            }
        }
    }
#endif
