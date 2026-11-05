# swift-matrix

Use this package when you need a fixed-size, stack-stored `Rows × Columns` grid of scalars with the dimensions checked at compile time: matrix products, applying a matrix to a `Vector<Columns, Scalar>`, transposition, and the matrix form of a `Scale`, `Shear` or `Rotation`. Start from `Matrix<Rows, Columns, Scalar>`. It carries no coordinate space; when the matrix is a linear map between tagged spaces, use `Linear.Matrix` from swift-linear, which wraps this type.

## Laws

- Storage is row-major: `rows[row][column]` is the entry `self[row, column]`, and `multiplied(by:)` and `applied(to:)` treat vectors as columns. `a.multiplied(by: b)` is the product `a · b`, so `a.multiplied(by: b).applied(to: v) == a.applied(to: b.applied(to: v))` in exact arithmetic. With floating-point scalars the two sides can differ by rounding.
- Every product entry starts at `.zero` and accumulates the terms in increasing inner index, one addition at a time. Floating-point results therefore match that left-to-right sum exactly, including its rounding.
- A product over a zero inner dimension is the zero matrix, and a product with a zero outer dimension keeps its shape. `transposed` applied twice returns the original matrix.
- Equality and hashing are entry by entry, and all matrices with no entries are equal.
- `Matrix(scale)` is diagonal with the scale's factors on the diagonal and exact zeros elsewhere. Non-finite factors are copied unchanged. `Matrix(first.concatenating(second)) == Matrix(second).multiplied(by: Matrix(first))`.
- `Matrix(shear)` is the identity plus the shear's factor at `[target, source]`. Composing two shears multiplies their matrices; it does not add their off-diagonal factors.
- `Matrix(rotation)` starts from the identity and applies `rotation.planes` in order. Each plane rotates its `first` axis toward its `second` for a positive angle. `Matrix(a.followed(by: b))` equals `Matrix(b).multiplied(by: Matrix(a))` up to rounding, and the result is orthonormal up to rounding. The conversion forgets parameters: a full-turn rotation gives a matrix that is approximately the identity even though the rotation is not `.identity`.
