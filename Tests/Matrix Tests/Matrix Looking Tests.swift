import Matrix
import Testing

extension `Matrix Tests` {
    @Suite struct `Looking at a target is a view transform` {
        typealias Map = Matrix<4, 4, Double>

        static let eyes: [(eye: Vector<3, Double>, target: Vector<3, Double>, up: Vector<3, Double>)] = [
            (Vector(x: 0, y: 0, z: 5), Vector(x: 0, y: 0, z: 0), Vector(x: 0, y: 1, z: 0)),
            (Vector(x: 3, y: -2, z: 7), Vector(x: -1, y: 4, z: 0.5), Vector(x: 0, y: 1, z: 0)),
            (Vector(x: 1, y: 1, z: 1), Vector(x: 2, y: 3, z: -4), Vector(x: 0.3, y: -0.2, z: 1)),
        ]

        static func point(_ map: Map, _ point: Vector<3, Double>) -> Vector<4, Double> {
            map.applied(to: Vector([point[0], point[1], point[2], 1]))
        }

        @Test func `The eye goes to the origin and the target onto negative z`() throws {
            for (eye, target, up) in Self.eyes {
                let view = try Map.looking(at: target, from: eye, up: up)
                let origin = Self.point(view, eye)
                #expect(abs(origin[0]) < 1e-12 && abs(origin[1]) < 1e-12 && abs(origin[2]) < 1e-12)
                let seen = Self.point(view, target)
                let distance = (target - eye).dot(target - eye).squareRoot()
                #expect(abs(seen[0]) < 1e-12 && abs(seen[1]) < 1e-12)
                #expect(abs(seen[2] + distance) < 1e-12)
            }
        }

        @Test func `Up lands in the upper half and the turn is orthonormal`() throws {
            for (eye, target, up) in Self.eyes {
                let view = try Map.looking(at: target, from: eye, up: up)
                let lifted = view.applied(to: Vector([up[0], up[1], up[2], 0]))
                #expect(lifted[1] > 0)
                #expect(abs(lifted[0]) < 1e-12)
                let turn = Matrix<3, 3, Double>(
                    rows: InlineArray { row in InlineArray { column in view[row, column] } }
                )
                let product = turn.multiplied(by: turn.transposed)
                (0..<3).forEach { row in
                    (0..<3).forEach { column in
                        #expect(abs(product[row, column] - (row == column ? 1 : 0)) < 1e-12)
                    }
                }
            }
        }

        @Test func `Looking from the default eye down negative z is the identity`() throws {
            let view = try Map.looking(at: Vector(x: 0, y: 0, z: -1), from: .zero, up: Vector(x: 0, y: 1, z: 0))
            #expect(view == .identity)
        }

        @Test func `No turn is determined when the target is the eye or up is the line of sight`() {
            let eye = Vector<3, Double>(x: 1, y: 2, z: 3)
            #expect(throws: Map.Error.singular) { try Map.looking(at: eye, from: eye, up: Vector(x: 0, y: 1, z: 0)) }
            #expect(throws: Map.Error.singular) {
                try Map.looking(at: Vector(x: 1, y: 5, z: 3), from: eye, up: Vector(x: 0, y: 2, z: 0))
            }
        }
    }
}
