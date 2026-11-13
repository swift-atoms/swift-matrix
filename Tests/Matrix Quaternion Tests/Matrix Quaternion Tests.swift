#if Quaternion
    import Foundation
    import Matrix
    import Testing

    enum `Matrix Quaternion Tests` {}

    extension `Matrix Quaternion Tests` {
        /// The rotation by `angle` about the axis (x, y, z), normalised.
        static func turn(_ angle: Double, _ x: Double, _ y: Double, _ z: Double) -> Quaternion<Double> {
            let length = (x * x + y * y + z * z).squareRoot()
            let sine = Foundation.sin(angle / 2) / length
            return Quaternion(w: Foundation.cos(angle / 2), x: x * sine, y: y * sine, z: z * sine)
        }

        /// The largest difference between entries.
        static func distance(_ a: Matrix<3, 3, Double>, _ b: Matrix<3, 3, Double>) -> Double {
            [0, 1, 2].flatMap { row in [0, 1, 2].map { column in abs(a[row, column] - b[row, column]) } }.max() ?? 0
        }

        /// The largest difference between parts, up to sign.
        static func distance(_ a: Quaternion<Double>, _ b: Quaternion<Double>) -> Double {
            func apart(_ b: Quaternion<Double>) -> Double {
                [abs(a.w - b.w), abs(a.x - b.x), abs(a.y - b.y), abs(a.z - b.z)].max() ?? 0
            }
            return min(apart(b), apart(-b))
        }

        /// Rotations that reach every branch of Shepperd's method: positive trace, and half turns
        /// whose largest diagonal entry is each of the three.
        static let samples: [Quaternion<Double>] = [
            .identity,
            turn(0.3, 1, 0, 0),
            turn(-1.2, 0, 0, 1),
            turn(1.7, 1, 2, 3),
            turn(3.1, 1, 0.1, 0.2),
            turn(3.1, 0.1, 1, 0.2),
            turn(3.1, 0.1, 0.2, 1),
            turn(Double.pi, 0, 0, 1),
            turn(Double.pi, 1, 1, 0),
        ]
    }

    extension `Matrix Quaternion Tests` {
        @Suite struct `Quaternion matrix conversion` {
            @Test func `A unit quaternion gives a rotation matrix`() {
                `Matrix Quaternion Tests`.samples.forEach { quaternion in
                    let matrix = Matrix(quaternion)
                    let product = matrix.multiplied(by: matrix.transposed)
                    #expect(`Matrix Quaternion Tests`.distance(product, .identity) <= 1e-15)
                    let determinant =
                        matrix[0, 0] * (matrix[1, 1] * matrix[2, 2] - matrix[1, 2] * matrix[2, 1])
                        - matrix[0, 1] * (matrix[1, 0] * matrix[2, 2] - matrix[1, 2] * matrix[2, 0])
                        + matrix[0, 2] * (matrix[1, 0] * matrix[2, 1] - matrix[1, 1] * matrix[2, 0])
                    #expect(abs(determinant - 1) <= 1e-15)
                }
            }

            @Test func `A quarter turn about z moves x to y`() {
                let matrix = Matrix(`Matrix Quaternion Tests`.turn(Double.pi / 2, 0, 0, 1))
                let moved = matrix.applied(to: Vector([1, 0, 0]))
                #expect(abs(moved[0]) <= 1e-15)
                #expect(abs(moved[1] - 1) <= 1e-15)
                #expect(abs(moved[2]) <= 1e-15)
            }

            @Test func `The product of quaternions is the product of matrices`() {
                `Matrix Quaternion Tests`.samples.forEach { a in
                    `Matrix Quaternion Tests`.samples.forEach { b in
                        let composed = Matrix(a.multiplied(by: b))
                        let product = Matrix(a).multiplied(by: Matrix(b))
                        #expect(`Matrix Quaternion Tests`.distance(composed, product) <= 1e-14)
                    }
                }
            }

            @Test func `A matrix's quaternion has the same rotation and a non-negative real part`() {
                `Matrix Quaternion Tests`.samples.forEach { quaternion in
                    let back = Quaternion(Matrix(quaternion))
                    #expect(back.w >= 0)
                    #expect(`Matrix Quaternion Tests`.distance(back, quaternion) <= 1e-14)
                    #expect(`Matrix Quaternion Tests`.distance(Matrix(back), Matrix(quaternion)) <= 1e-14)
                }
                #expect(Quaternion(Matrix<3, 3, Double>.identity) == .identity)
                #expect(Matrix(Quaternion<Double>.identity) == .identity)
            }

            @Test func `The conjugate gives the transposed matrix`() {
                `Matrix Quaternion Tests`.samples.forEach { quaternion in
                    let distance = `Matrix Quaternion Tests`.distance(Matrix(quaternion.conjugate), Matrix(quaternion).transposed)
                    #expect(distance <= 1e-15)
                }
            }
        }
    }
#endif
