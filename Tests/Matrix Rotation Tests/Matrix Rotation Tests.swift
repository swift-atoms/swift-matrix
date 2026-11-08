#if Rotation && Trigonometry
    public import Matrix
    import Foundation
    import Testing

    extension Double: @retroactive Trigonometry.Circular {
        public static func sin(_ x: Double) -> Double { Foundation.sin(x) }
        public static func cos(_ x: Double) -> Double { Foundation.cos(x) }
        public static func tan(_ x: Double) -> Double { Foundation.tan(x) }
        public static func asin(_ x: Double) -> Double { Foundation.asin(x) }
        public static func acos(_ x: Double) -> Double { Foundation.acos(x) }
        public static func atan(_ x: Double) -> Double { Foundation.atan(x) }
        public static func atan2(_ y: Double, _ x: Double) -> Double { Foundation.atan2(y, x) }
    }

enum `Matrix Rotation Tests` {}

extension `Matrix Rotation Tests` {
        @Suite struct `Rotation matrix evaluation` {
            @Test func `Empty rotations produce identity including zero and one dimensions`() {
                let empty = Matrix(Rotation<0, Double>.identity)
                #expect(empty == Matrix<0, 0, Double>(repeating: 0))
                #expect(Matrix(Rotation<1, Double>.identity)[0, 0] == 1)
                let identity = Matrix(Rotation<3, Double>.identity)
                (0..<3).forEach { row in
                    (0..<3).forEach { column in #expect(identity[row, column] == (row == column ? 1 : 0)) }
                }
            }

            @Test(arguments: [0.0, Double.pi / 2, -Double.pi / 2, Double.pi, Double.pi * 2])
            func `Positive angles map the first basis vector toward the second`(angle: Double) throws {
                let plane = try Rotation<2, Double>.Plane(first: .primary, second: .secondary, angle: Radian(_unchecked: angle))
                let rotation = Rotation(plane)
                let matrix = Matrix(rotation)
                let moved = matrix.applied(to: Vector(x: 1.0, y: 0.0))
                #expect(abs(moved[0] - Foundation.cos(angle)) < 1e-12)
                #expect(abs(moved[1] - Foundation.sin(angle)) < 1e-12)
                #expect(abs(matrix[0, 0] * matrix[1, 1] - matrix[0, 1] * matrix[1, 0] - 1) < 1e-12)
                #expect(rotation.matrix == matrix)
            }

            @Test func `Different planes compose in the documented noncommuting order`() throws {
                let xy = Rotation(try Rotation<3, Double>.Plane(first: .primary, second: .secondary, angle: Radian(_unchecked: .pi / 2)))
                let yz = Rotation(try Rotation<3, Double>.Plane(first: .secondary, second: .tertiary, angle: Radian(_unchecked: .pi / 2)))
                let unit = Vector(x: 1.0, y: 0.0, z: 0.0)
                let forward = Matrix(xy.followed(by: yz)).applied(to: unit)
                let backward = Matrix(yz.followed(by: xy)).applied(to: unit)
                #expect(abs(forward[2] - 1) < 1e-12)
                #expect(abs(backward[1] - 1) < 1e-12)
                #expect(abs(forward[1]) < 1e-12)
                let expected = Matrix(yz).multiplied(by: Matrix(xy))
                let actual = Matrix(xy.followed(by: yz))
                (0..<3).forEach { row in
                    (0..<3).forEach { column in #expect(abs(expected[row, column] - actual[row, column]) < 1e-12) }
                }
            }

            @Test func `Inverse restores vectors and orthonormality across arbitrary ordered axes`() throws {
                let first = try Rotation<4, Double>.Plane(first: Axis(3), second: Axis(0), angle: Radian(_unchecked: 0.71))
                let second = try Rotation<4, Double>.Plane(first: Axis(1), second: Axis(3), angle: Radian(_unchecked: -1.12))
                let rotation = Rotation(planes: [first, second, first])
                let matrix = Matrix(rotation)
                let vector = Vector<4, Double>([2, -3, 4, 5])
                let restored = Matrix(rotation.inverse).applied(to: matrix.applied(to: vector))
                (0..<4).forEach { index in #expect(abs(restored[index] - vector[index]) < 1e-12) }
                let product = matrix.transposed.multiplied(by: matrix)
                (0..<4).forEach { row in
                    (0..<4).forEach { column in #expect(abs(product[row, column] - (row == column ? 1 : 0)) < 1e-12) }
                }
            }

            @Test func `Full turns retain parameter identity even when matrices approximate identity`() throws {
                let rotation = Rotation(try Rotation<2, Double>.Plane(first: .primary, second: .secondary, angle: Radian(_unchecked: 2 * .pi)))
                #expect(rotation != .identity)
                let matrix = Matrix(rotation)
                #expect(abs(matrix[0, 0] - 1) < 1e-12)
                #expect(abs(matrix[0, 1]) < 1e-12)
                #expect(rotation.planes.count == 1)
            }
        }
}

    @Test func `Degree based legacy call sites convert through the angle owner before matrix evaluation`() throws {
        let angle = Radian(degrees: Degree<Double>(90))
        let rotation = Rotation(try Rotation<2, Double>.Plane(first: .primary, second: .secondary, angle: angle))
        let moved = Matrix(rotation).applied(to: Vector(x: 2.0, y: 3.0))
        #expect(abs(moved[0] + 3) < 1e-12)
        #expect(abs(moved[1] - 2) < 1e-12)
        #expect(rotation.planes[0].angle == angle)
    }
#endif
