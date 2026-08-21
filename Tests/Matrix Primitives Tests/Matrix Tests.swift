import Testing

@testable import Matrix_Primitives

extension Matrix {
    @Suite struct Tests {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Matrix.Tests.Unit {
    @Test
    func `Matrix namespace is an uninhabited enum`() {

        #expect(MemoryLayout<Matrix>.size == 0)
    }
}
