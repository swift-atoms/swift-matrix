import Matrix
import Testing

extension `Matrix Tests` {
    @Suite struct `A 4 × 4 matrix moves homogeneous points of space` {
        typealias Map = Matrix<4, 4, Int>

        @Test func `A linear part and a translation fill the top three rows`() {
            let linear = Matrix<3, 3, Int>(rows: [[1, 2, 3], [4, 5, 6], [7, 8, 9]])
            let map = Map(linear: linear, translation: Vector([10, 11, 12]))
            #expect(map == Map(rows: [[1, 2, 3, 10], [4, 5, 6, 11], [7, 8, 9, 12], [0, 0, 0, 1]]))
            #expect(Map(linear: .identity) == .identity)
        }

        @Test func `A translation moves points and leaves directions`() {
            let map = Map.translation(Vector([3, -4, 5]))
            #expect(map == Map(rows: [[1, 0, 0, 3], [0, 1, 0, -4], [0, 0, 1, 5], [0, 0, 0, 1]]))
            #expect(map.applied(to: Vector([1, 1, 1, 1])) == Vector([4, -3, 6, 1]))
            #expect(map.applied(to: Vector([1, 1, 1, 0])) == Vector([1, 1, 1, 0]))
            #expect(map.multiplied(by: .translation(Vector([1, 2, 3]))) == .translation(Vector([4, -2, 8])))
        }

        @Test func `A scale puts its factors on the diagonal and keeps the fourth coordinate`() {
            #expect(Map.scale(Vector([2, 3, 4])) == Map(rows: [[2, 0, 0, 0], [0, 3, 0, 0], [0, 0, 4, 0], [0, 0, 0, 1]]))
            #expect(Map.scale(5) == Map.scale(Vector([5, 5, 5])))
            #expect(Map.scale(2).applied(to: Vector([1, -2, 3, 1])) == Vector([2, -4, 6, 1]))
        }
    }
}
