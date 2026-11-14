import Matrix
import Testing

extension `Matrix Tests` {
    @Suite struct `A rigid motion is a rotation then a translation` {
        typealias Map = Matrix<4, 4, Double>
        typealias Rigid = Map.Rigid

        static let motions: [Map] = [
            .identity,
            .translation(Vector(x: 3, y: -2, z: 7)),
            Map(linear: Matrix(rows: [[0, -1, 0], [1, 0, 0], [0, 0, 1]]), translation: Vector(x: 1, y: 2, z: 3)),
            Map(linear: Matrix(rows: [[0.6, -0.8, 0], [0.8, 0.6, 0], [0, 0, 1]]), translation: Vector(x: -4, y: 0.5, z: 9)),
        ]

        static func views() throws -> [Map] {
            [
                try Map.looking(at: Vector(x: -1, y: 4, z: 0.5), from: Vector(x: 3, y: -2, z: 7), up: Vector(x: 0, y: 1, z: 0)),
                try Map.looking(at: Vector(x: 2, y: 3, z: -4), from: Vector(x: 1, y: 1, z: 1), up: Vector(x: 0.3, y: -0.2, z: 1)),
            ]
        }

        static func distance(_ a: Map, _ b: Map) -> Double {
            (0..<16).map { abs(a[$0 / 4, $0 % 4] - b[$0 / 4, $0 % 4]) }.max() ?? 0
        }

        @Test func `Taking a rigid matrix apart and putting it back gives the matrix exactly`() throws {
            for map in Self.motions + (try Self.views()) {
                let rigid = try #require(Rigid(map, within: 1e-12))
                #expect(rigid.matrix == map)
                #expect(rigid.rotation == map.linear)
                #expect(rigid.translation == map.translation)
                #expect(map.isRigid(within: 1e-12))
                let point = Vector<3, Double>(x: 0.25, y: -3, z: 5)
                let moved = map.applied(to: Vector([point[0], point[1], point[2], 1]))
                let applied = rigid.applied(to: point)
                #expect((0..<3).allSatisfy { abs(applied[$0] - moved[$0]) <= 1e-12 })
            }
        }

        @Test func `A matrix that is not rigid is refused`() {
            let refused: [Map] = [
                .scale(2),
                .scale(Vector(x: 1, y: 1, z: -1)),
                Map(linear: Matrix(rows: [[1, 0.5, 0], [0, 1, 0], [0, 0, 1]])),
                Map(rows: [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, -1, 0]]),
                Map(rows: [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 2]]),
                .translation(Vector(x: .infinity, y: 0, z: 0)),
                Map(linear: Matrix(rows: [[.nan, 0, 0], [0, 1, 0], [0, 0, 1]])),
            ]
            for map in refused {
                #expect(Rigid(map, within: 1e-6) == nil)
                #expect(!map.isRigid(within: 1e-6))
            }
            #expect(Rigid(rotation: Matrix(rows: [[0, 1, 0], [1, 0, 0], [0, 0, 1]]), translation: .zero, within: 1e-6) == nil)
            #expect(Rigid(.identity, within: .nan) == nil)
        }

        @Test func `The tolerance bounds how far from orthonormal a rotation may drift`() {
            let drifted = Matrix<3, 3, Double>(rows: [[1 + 1e-9, 0, 0], [0, 1, 0], [0, 0, 1]])
            #expect(drifted.isRotation(within: 1e-6))
            #expect(!drifted.isRotation(within: 1e-12))
            #expect(Rigid(rotation: drifted, translation: .zero, within: 1e-6) != nil)
            #expect(Matrix<3, 3, Double>.identity.isRotation(within: 0))
        }

        @Test func `The inverse undoes the motion on both sides`() throws {
            for map in Self.motions + (try Self.views()) {
                let rigid = try #require(Rigid(map, within: 1e-12))
                #expect(Self.distance(rigid.followed(by: rigid.inverse).matrix, .identity) <= 1e-14)
                #expect(Self.distance(rigid.inverse.followed(by: rigid).matrix, .identity) <= 1e-14)
                #expect(Self.distance(rigid.inverse.matrix.multiplied(by: map), .identity) <= 1e-14)
                #expect(rigid.inverse.matrix.isRigid(within: 1e-12))
            }
            #expect(Rigid.identity.inverse == .identity)
        }

        @Test func `Following one motion by another is the product of their matrices`() throws {
            let all = Self.motions + (try Self.views())
            for first in all {
                for second in all {
                    let a = try #require(Rigid(first, within: 1e-12))
                    let b = try #require(Rigid(second, within: 1e-12))
                    #expect(Self.distance(a.followed(by: b).matrix, second.multiplied(by: first)) <= 1e-13)
                }
            }
        }
    }
}

#if Quaternion && Rotation && Trigonometry
    import Foundation

    extension `Matrix Tests` {
        @Suite struct `Interpolating rigid motions turns evenly and moves straight` {
            typealias Map = Matrix<4, 4, Double>
            typealias Rigid = Map.Rigid

            static func turn(_ angle: Double) -> Matrix<3, 3, Double> {
                Map.rotation(aboutZ: angle).linear
            }

            @Test func `The ends come back exactly`() throws {
                let start = try #require(Rigid(rotation: Self.turn(0.3), translation: Vector(x: 1, y: 2, z: 3), within: 1e-12))
                let end = try #require(Rigid(rotation: Self.turn(2.1), translation: Vector(x: -5, y: 0, z: 8), within: 1e-12))
                #expect(start.interpolated(to: end, at: 0) == start)
                #expect(start.interpolated(to: end, at: 1) == end)
            }

            @Test func `Half way along a quarter turn is an eighth turn, with the translation half way`() throws {
                let start = try #require(Rigid(rotation: .identity, translation: .zero, within: 0))
                let end = try #require(Rigid(rotation: Self.turn(Double.pi / 2), translation: Vector(x: 2, y: 4, z: 6), within: 1e-12))
                let middle = start.interpolated(to: end, at: 0.5)
                let eighth = Self.turn(Double.pi / 4)
                #expect((0..<9).allSatisfy { abs(middle.rotation[$0 / 3, $0 % 3] - eighth[$0 / 3, $0 % 3]) <= 1e-15 })
                #expect(middle.translation == Vector(x: 1, y: 2, z: 3))
                #expect(middle.rotation.isRotation(within: 1e-15))
            }
        }
    }
#endif
