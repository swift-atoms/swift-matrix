import Matrix
import Testing

extension `Matrix Tests` {
    @Suite struct `A 3 × 3 matrix is a projective map of the plane` {
        typealias Map = Matrix<3, 3, Double>

        static let square: InlineArray<4, Vector<2, Double>> = [Vector([0, 0]), Vector([1, 0]), Vector([1, 1]), Vector([0, 1])]
        static let card: InlineArray<4, Vector<2, Double>> = [Vector([10, 20]), Vector([90, 30]), Vector([80, 70]), Vector([25, 60])]

        static func near(_ a: Vector<2, Double>, _ b: Vector<2, Double>, _ tolerance: Double = 1e-9) -> Bool {
            abs(a[0] - b[0]) <= tolerance && abs(a[1] - b[1]) <= tolerance
        }

        @Test func `The fit takes each corner onto its target`() throws {
            let map = try Map(fitting: Self.square, onto: Self.card)
            for index in 0..<4 { #expect(Self.near(map.projected(Self.square[index]), Self.card[index])) }
            let wide: InlineArray<4, Vector<2, Double>> = [Vector([0, 0]), Vector([640, 0]), Vector([640, 360]), Vector([0, 360])]
            let other = try Map(fitting: wide, onto: Self.card)
            for index in 0..<4 { #expect(Self.near(other.projected(wide[index]), Self.card[index])) }
        }

        @Test func `The fit keeps straight lines straight and is not affine for a trapezoid`() throws {
            let map = try Map(fitting: Self.square, onto: Self.card)
            let ends = (map.projected(Vector([0, 0.5])), map.projected(Vector([1, 0.5])))
            let middle = map.projected(Vector([0.3, 0.5]))
            let cross = (ends.1[0] - ends.0[0]) * (middle[1] - ends.0[1]) - (ends.1[1] - ends.0[1]) * (middle[0] - ends.0[0])
            #expect(abs(cross) < 1e-9)
            #expect(map[2, 0] != 0 || map[2, 1] != 0)
        }

        @Test func `A parallelogram fits an affine map`() throws {
            let parallelogram: InlineArray<4, Vector<2, Double>> = [Vector([1, 2]), Vector([5, 3]), Vector([6, 7]), Vector([2, 6])]
            let map = try Map(fitting: Self.square, onto: parallelogram)
            #expect(abs(map[2, 0]) < 1e-12 && abs(map[2, 1]) < 1e-12 && map[2, 2] == 1)
        }

        @Test func `The inverse undoes the map`() throws {
            let map = try Map(fitting: Self.square, onto: Self.card)
            let inverse = try map.inverted()
            let point = Vector<2, Double>([0.25, 0.75])
            #expect(Self.near(inverse.projected(map.projected(point)), point))
            #expect(throws: Matrix<3, 3, Double>.Error.singular) { try Map(repeating: 1).inverted() }
        }

        @Test func `Three points on a line fit nothing`() {
            let line: InlineArray<4, Vector<2, Double>> = [Vector([0, 0]), Vector([1, 1]), Vector([2, 2]), Vector([0, 1])]
            #expect(throws: Matrix<3, 3, Double>.Error.singular) { try Map(fitting: Self.square, onto: line) }
        }

        @Test func `An affine map lifted projects as it applies`() {
            let affine = Matrix<2, 3, Double>(rows: [[0.5, -1.25, 3], [2, 0.75, -4]])
            let point = Vector<2, Double>([1.1, -2.3])
            #expect(Map(affine).projected(point) == affine.applied(to: point))
        }
    }
}
