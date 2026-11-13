import Matrix
import Testing

extension `Matrix Tests` {
    @Suite struct `A 2 × 3 matrix is an affine map of the plane` {
        typealias Map = Matrix<2, 3, Int>

        static let turn = Map(rows: [[0, -1, 5], [1, 0, -2]])
        static let stretch = Map(rows: [[2, 3, 7], [0, -4, 1]])

        @Test func `Applying to a point is applying to its homogeneous column`() {
            let point = Vector<2, Int>([3, 4])
            #expect(Self.stretch.applied(to: point) == Vector([25, -15]))
            #expect(Self.stretch.applied(to: point) == Self.stretch.applied(to: Vector<3, Int>([3, 4, 1])))
        }

        @Test func `The product applies its right operand first`() {
            let point = Vector<2, Int>([3, 4])
            let product = Self.turn.multiplied(by: Self.stretch)
            #expect(product == Map(rows: [[0, 4, 4], [2, 3, 5]]))
            #expect(product.applied(to: point) == Self.turn.applied(to: Self.stretch.applied(to: point)))
            #expect(product != Self.stretch.multiplied(by: Self.turn))
        }

        @Test func `The product is the top of the homogeneous 3 × 3 product`() {
            let left = Matrix<3, 3, Int>(rows: [[0, -1, 5], [1, 0, -2], [0, 0, 1]])
            let right = Matrix<3, 3, Int>(rows: [[2, 3, 7], [0, -4, 1], [0, 0, 1]])
            let full = left.multiplied(by: right)
            let product = Self.turn.multiplied(by: Self.stretch)
            (0..<2).forEach { row in
                (0..<3).forEach { column in #expect(product[row, column] == full[row, column]) }
            }
        }

        @Test func `The identity is neutral on both sides and moves no point`() {
            #expect(Map.identity == Map(rows: [[1, 0, 0], [0, 1, 0]]))
            #expect(Map.identity.multiplied(by: Self.stretch) == Self.stretch)
            #expect(Self.stretch.multiplied(by: Map.identity) == Self.stretch)
            #expect(Map.identity.applied(to: Vector([3, 4])) == Vector([3, 4]))
        }

        @Test func `Translations add their offsets`() {
            let first = Map.translation(Vector([3, -4]))
            let second = Map.translation(Vector([10, 20]))
            #expect(first == Map(rows: [[1, 0, 3], [0, 1, -4]]))
            #expect(first.multiplied(by: second) == Map.translation(Vector([13, 16])))
            #expect(first.applied(to: Vector([1, 1])) == Vector([4, -3]))
        }

        @Test func `Linear part and translation rebuild the map`() {
            #expect(Self.stretch.linear == Matrix<2, 2, Int>(rows: [[2, 3], [0, -4]]))
            #expect(Self.stretch.translation == Vector([7, 1]))
            #expect(Map(linear: Self.stretch.linear, translation: Self.stretch.translation) == Self.stretch)
            #expect(Map(linear: Self.stretch.linear) == Map(rows: [[2, 3, 0], [0, -4, 0]]))
        }

        @Test func `A linear map about a point keeps that point where it is`() {
            let center = Vector<2, Int>([3, -2])
            let map = Map(linear: Self.stretch.linear, about: center)
            #expect(map.applied(to: center) == center)
            #expect(map.linear == Self.stretch.linear)
            let conjugated = Map.translation(center).multiplied(by: Map(linear: Self.stretch.linear))
                .multiplied(by: Map.translation(Vector([-3, 2])))
            #expect(map == conjugated)
            #expect(Map(linear: Self.stretch.linear, about: .zero) == Map(linear: Self.stretch.linear))
        }

        @Test func `A scale about a point is the factor on the diagonal with the point kept`() {
            #expect(Map.scale(Vector([2, 3])) == Map(rows: [[2, 0, 0], [0, 3, 0]]))
            #expect(Map.scale(4) == Map(rows: [[4, 0, 0], [0, 4, 0]]))
            #expect(Map.scale(Vector([2, 3]), about: Vector([5, 7])) == Map(rows: [[2, 0, -5], [0, 3, -14]]))
            #expect(Map.scale(2, about: Vector([5, 7])).applied(to: Vector([5, 7])) == Vector([5, 7]))
            #expect(Map.scale(2, about: Vector([5, 7])).applied(to: Vector([6, 9])) == Vector([7, 11]))
        }

        @Test func `A scale about a point gives the translation as the point less the factor times the point`() {
            let (factor, x, y) = (1.37, 812.4, -33.9)
            let map = Matrix<2, 3, Double>.scale(factor, about: Vector([x, y]))
            #expect(map == Matrix<2, 3, Double>(rows: [[factor, 0, x - factor * x], [0, factor, y - factor * y]]))
        }
    }
}

extension `Matrix Tests` {
    @Suite struct `Inversion undoes a map and refuses a singular one` {
        @Test func `A 2 × 2 inverse divides the adjugate by the determinant`() throws {
            let matrix = Matrix<2, 2, Double>(rows: [[4, 7], [2, 6]])
            #expect(matrix.determinant == 10)
            #expect(try matrix.inverted() == Matrix<2, 2, Double>(rows: [[0.6, -0.7], [-0.2, 0.4]]))
        }

        @Test func `An affine inverse undoes the map on both sides`() throws {
            let map = Matrix<2, 3, Double>(rows: [[2, 0, 6], [0, 4, -8]])
            let inverse = try map.inverted()
            #expect(inverse == Matrix<2, 3, Double>(rows: [[0.5, 0, -3], [0, 0.25, 2]]))
            #expect(inverse.multiplied(by: map) == .identity)
            #expect(map.multiplied(by: inverse) == .identity)
            #expect(inverse.applied(to: map.applied(to: Vector([3, 5]))) == Vector([3, 5]))
        }

        @Test func `A translation inverts to the opposite translation`() throws {
            let inverse = try Matrix<2, 3, Double>.translation(Vector([3, -4])).inverted()
            #expect(inverse == .translation(Vector([-3, 4])))
        }

        @Test func `A zero determinant is the singular failure`() {
            let flat = Matrix<2, 2, Double>(rows: [[1, 2], [2, 4]])
            #expect(throws: Matrix<2, 2, Double>.Error.singular) { try flat.inverted() }
            let map = Matrix<2, 3, Double>(linear: flat, translation: Vector([1, 1]))
            #expect(throws: Matrix<2, 3, Double>.Error.singular) { try map.inverted() }
        }

        @Test func `A nearly singular matrix still inverts`() throws {
            let thin = Matrix<2, 2, Double>(rows: [[1, 0], [0, 0x1p-1000]])
            #expect(try thin.inverted() == Matrix<2, 2, Double>(rows: [[1, 0], [0, 0x1p1000]]))
        }
    }
}

extension `Matrix Tests` {
    @Suite struct `The square identity has ones on its diagonal only` {
        @Test func `Identity is neutral for the product`() {
            let matrix = Matrix<3, 3, Int>(rows: [[1, 2, 3], [4, 5, 6], [7, 8, 9]])
            #expect(Matrix<3, 3, Int>.identity == Matrix(rows: [[1, 0, 0], [0, 1, 0], [0, 0, 1]]))
            #expect(matrix.multiplied(by: .identity) == matrix)
            #expect(Matrix<3, 3, Int>.identity.multiplied(by: matrix) == matrix)
            #expect(Matrix<0, 0, Int>.identity == .zero)
        }
    }
}

extension `Matrix Tests` {
    @Suite struct `The affine map nearest to point correspondences is their least-squares fit` {
        typealias Map = Matrix<2, 3, Double>
        typealias Point = Vector<2, Double>

        static let square: InlineArray<4, Point> = [Point([0, 0]), Point([1, 0]), Point([1, 1]), Point([0, 1])]
        static let skew = Map(rows: [[3, 1.5, -2], [-0.5, 2, 7]])
        static let quadrilateral: InlineArray<4, Point> = [Point([0.1, -0.2]), Point([2.3, 0.4]), Point([1.9, 1.6]), Point([-0.3, 1.1])]

        static func near(_ a: Map, _ b: Map, within tolerance: Double = 1e-12) -> Bool {
            (0..<2).allSatisfy { row in (0..<3).allSatisfy { column in abs(a[row, column] - b[row, column]) <= tolerance } }
        }

        static func residual(_ map: Map, _ sources: InlineArray<4, Point>, _ targets: InlineArray<4, Point>) -> Double {
            sources.indices.reduce(0) { sum, index in
                let miss = map.applied(to: sources[index]) - targets[index]
                return sum + miss[0] * miss[0] + miss[1] * miss[1]
            }
        }

        static func moved(_ points: InlineArray<4, Point>, by map: Map) -> InlineArray<4, Point> {
            InlineArray { index in map.applied(to: points[index]) }
        }

        @Test func `A square onto a parallelogram fits exactly`() throws {
            let corners = Self.moved(Self.square, by: Self.skew)
            #expect(Self.near(try Map(fitting: Self.square, onto: corners), Self.skew))
            let rectangle: InlineArray<4, Point> = [Point([2, 3]), Point([6, 3]), Point([6, 4]), Point([2, 4])]
            #expect(Self.near(try Map(fitting: rectangle, onto: Self.moved(rectangle, by: Self.skew)), Self.skew))
        }

        @Test func `Three points not on a line fit exactly`() throws {
            let sources: InlineArray<3, Point> = [Point([0, 0]), Point([4, 1]), Point([-1, 3])]
            let targets: InlineArray<3, Point> = InlineArray { index in Self.skew.applied(to: sources[index]) }
            #expect(Self.near(try Map(fitting: sources, onto: targets), Self.skew, within: 1e-11))
        }

        @Test func `No nearby map has a smaller sum of squared distances`() throws {
            let fit = try Map(fitting: Self.square, onto: Self.quadrilateral)
            let best = Self.residual(fit, Self.square, Self.quadrilateral)
            #expect(best > 0)
            (0..<2).forEach { row in
                (0..<3).forEach { column in
                    for step in [1e-3, -1e-3, 0.1, -0.1] {
                        var nudged = fit
                        nudged[row, column] += step
                        #expect(Self.residual(nudged, Self.square, Self.quadrilateral) > best)
                    }
                }
            }
        }

        @Test func `The misses sum to zero and are uncorrelated with the sources`() throws {
            let fit = try Map(fitting: Self.square, onto: Self.quadrilateral)
            var total: Point = .zero
            var weighted = Matrix<2, 2, Double>.zero
            Self.square.indices.forEach { index in
                let miss = fit.applied(to: Self.square[index]) - Self.quadrilateral[index]
                total = total + miss
                (0..<2).forEach { row in
                    (0..<2).forEach { column in weighted[row, column] += miss[row] * Self.square[index][column] }
                }
            }
            #expect(abs(total[0]) < 1e-12 && abs(total[1]) < 1e-12)
            (0..<2).forEach { row in (0..<2).forEach { column in #expect(abs(weighted[row, column]) < 1e-12) } }
        }

        @Test func `Translating the targets translates the fit, and translating the sources precedes it`() throws {
            let fit = try Map(fitting: Self.square, onto: Self.quadrilateral)
            let offset = Point([12.5, -40])
            let shifted = Self.moved(Self.quadrilateral, by: .translation(offset))
            #expect(Self.near(try Map(fitting: Self.square, onto: shifted), Map.translation(offset).multiplied(by: fit)))
            let sources = Self.moved(Self.square, by: .translation(offset))
            let back = Map.translation(Point([-12.5, 40]))
            #expect(Self.near(try Map(fitting: sources, onto: Self.quadrilateral), fit.multiplied(by: back), within: 1e-11))
        }

        @Test func `Sources on one line, or none, are the singular failure`() {
            let line: InlineArray<4, Point> = [Point([0, 0]), Point([1, 1]), Point([2, 2]), Point([3, 3])]
            #expect(throws: Map.Error.singular) { try Map(fitting: line, onto: Self.quadrilateral) }
            let coincident: InlineArray<4, Point> = [Point([1, 2]), Point([1, 2]), Point([1, 2]), Point([1, 2])]
            #expect(throws: Map.Error.singular) { try Map(fitting: coincident, onto: Self.quadrilateral) }
            let none: InlineArray<0, Point> = []
            #expect(throws: Map.Error.singular) { try Map(fitting: none, onto: none) }
        }
    }
}
