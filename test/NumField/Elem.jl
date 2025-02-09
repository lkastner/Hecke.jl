@testset "NumField/Elem" begin
  Qx, x = PolynomialRing(FlintQQ, "x")
  QasNumberField, _ = NumberField(x - 1)
  Kt, t = PolynomialRing(QasNumberField, "t")
  K1, a1 = NumberField(x^3 - 2)
  K2, (a2, ) = NumberField([x^3 - 2])
  K3, a3 = NumberField(t^3 - 2)
  K4, (a4, ) = NumberField([t^3 - 2])

  @testset for (K, a) in [(K1, a1), (K2, a2), (K3, a3), (K4, a4)]
    b = one(K)
    fl = @inferred isintegral(b)
    @test fl
    fl = @inferred isintegral(a)
    OK = maximal_order(K)
    @test isintegral(a)
    @test isintegral(b)


    B = @inferred basis(K)
    c = @inferred basis_matrix([one(K), a^4])
    @assert nrows(c) == 2
    @assert ncols(c) == 3
    @assert sum(B[i] * c[1, i] for i in 1:3) == one(K)
    @assert sum(B[i] * c[2, i] for i in 1:3) == a^4

    f = @inferred charpoly(one(K()))
    @test f == (gen(parent(f)) - 1)^3
    f = @inferred minpoly(one(K))
    @test f == (gen(parent(f)) - 1)

    f = @inferred charpoly(a)
    @test f == gen(parent(f))^3 - 2
    f = @inferred minpoly(a)
    @test f == gen(parent(f))^3 - 2

  end

  @testset "NumField/Component" begin
    Qx, x = PolynomialRing(FlintQQ, "x")
    QasNumberField, _ = NumberField(x - 1)
    Kt, t = PolynomialRing(QasNumberField, "t")
    K3, a3 = NumberField(t^3 - 2)
    K4, (a4, ) = NumberField([t^3 - 2])
    K41, mK4 = component(K4, 1)
    @test isisomorphic(K41, K3)[1]
    @test mK4(gen(K41)) == a4


    K1, a1 = NumberField(x^3 - 2)
    K2, (a2, ) = NumberField([x^3 - 2])
    K21, mK2 = component(K2, 1)
    @test isisomorphic(K21, K1)[1]
    @test mK2(gen(K21)) == a2
  end

  @testset "rand" begin
    Qx, x = PolynomialRing(FlintQQ, "x")
    K, a = NumberField(x^3 - 2)
    v = [a^0, a^2]
    @assert elem_type(K) == nf_elem
    for args = ((v, 1:3), (v, 1:3, 2))
      m = make(K, args...)
      for x in (rand(args...), rand(rng, args...),
                rand(m), rand(rng, m))
        @test x isa nf_elem
      end
      @test rand(m, 3) isa Vector{nf_elem}
      c = zero(K)
      @test c === rand!(c, m)
      @test c === rand!(rng, c, m)
      @test c === rand!(c, args...)
      @test c === rand!(rng, c, args...)
      @test reproducible(m)
      @test reproducible(args...)
    end
  end

  @testset "NumField/Coordinates" begin
    Qx, x = PolynomialRing(FlintQQ, "x")
    K, a = number_field(x^2+1, cached = false)
    BK = basis(K)
    for i = 1:5
      el = rand(K, -5:5)
      v = coordinates(el)
      @test el == dot(v, BK)
    end
    Kns, gKns = number_field([x^2+1, x^2+2], check = false)
    BKns = basis(Kns)
    for i = 1:5
      el = rand(Kns, -5:5)
      v = coordinates(el)
      @test el == dot(v, BKns)
    end
    Kt, t = PolynomialRing(K, "t", cached = false)
    L, gL = number_field(t^2+3, cached = false)
    BL = basis(L)
    BLabs = absolute_basis(L)
    for i = 1:5
      el = rand(L, -5:5)
      v = coordinates(el)
      vabs = absolute_coordinates(el)
      @test el == dot(v, BL)
      @test el == dot(vabs, BLabs)
    end
    Lns, gLns = number_field([t^2+3, t^2+5], check = false, cached = false)
    BLns = basis(Lns)
    BLnsabs = absolute_basis(Lns)
    for i = 1:5
      el = rand(Lns, -5:5)
      v = coordinates(el)
      vabs = absolute_coordinates(el)
      @test el == dot(v, BLns)
      @test el == dot(vabs, BLnsabs)
    end
    Knsy, y = PolynomialRing(Kns, "y", cached = false)
    F, gF = number_field(y^2+7, cached = false)
    BF = basis(F)
    BFabs = absolute_basis(F)
    for i = 1:5
      el = rand(F, -5:5)
      v = coordinates(el)
      vabs = absolute_coordinates(el)
      @test el == dot(v, BF)
      @test el == dot(vabs, BFabs)
    end
    Fns, gFns = number_field([y^2+7, y^2+11], cached = false)
    BFns = basis(Fns)
    BFnsabs = absolute_basis(Fns)
    for i = 1:5
      el = rand(Fns, -5:5)
      v = coordinates(el)
      vabs = absolute_coordinates(el)
      @test el == dot(v, BFns)
      @test el == dot(vabs, BFnsabs)
    end
    Fnsz, z = PolynomialRing(Fns, "z", cached = false)
    N, gN = number_field([z^2+17, z^2+19], check = false, cached = false)
    BN = basis(N)
    BNabs = absolute_basis(N)
    for i = 1:5
      el = rand(N, -5:5)
      v = coordinates(el)
      vabs = absolute_coordinates(el)
      @test el == dot(v, BN)
      @test el == dot(vabs, BNabs)
    end
  end

  @testset "relative extension" begin
    Qx, x = FlintQQ["x"]
    f = x^2 + 12x - 92
    K, a = NumberField(f, "a")
    Ky, y = K["y"]
    L, b = NumberField(y^2 + y + 1, "b")
    Lt, t = PolynomialRing(L)
    L1, gL1 = number_field([t^3-2])
    L1rel, mL1rel = relative_simple_extension(L1, K)
    el = mL1rel(gen(L1rel))
    @test isprimitive_over(el, K)

  end
end

@testset "issquare" begin
  #Enable one issquare is working for non-monic defining polynomials
  Qx, x = QQ["x"]
  rangee = deleteat!(collect(-10:10), 11) # remove 0
  for d in [2,3,4,6,8,10]
    f = rand(Qx, d:d, -10:10)
    while !isirreducible(f)
      f = rand(Qx, d:d, -10:10)
    end
    K, a = NumberField(f)
    for m in 1:100
      b = rand(K, -10:10)//rand(rangee)
      c = b^2
      fl, d = issquare_with_sqrt(c)
      @test fl
      @test d^2 == c
      b = rand(K, -10:10)
      KK, m = simplify(K)
      @test issquare(b) == issquare(m\b)
    end
  end

  f = -6//7*x + 1//9
  K, a = number_field(f, cached = false)
  c = 49//4
  fl, b = issquare_with_sqrt(K(c))
  @test fl
  @test b^2 == c

  K, a = number_field(1//4*x^3 + 3*x^2 + 2*x - 1, cached = false)
  b = -1//10*a^2 - 2//5*a - 3//5
  fl, c = issquare_with_sqrt(b^2)
  @test fl
  @test c^2 == b^2
end


@testset "Torsion units" begin
  Qx, x = QQ["x"]
  f = x^2 + 3
  K, a = NumberField(f, "a")
  G, mG = torsion_unit_group(K)
  @test order(G) == 6
  g = mG(G[1])
  @test g == torsion_units_generator(K)
  @test isone(g^6)
  @test !isone(g^3)
  @test !isone(g^2)
  @test Hecke.istorsion_unit_group_known(K)
  M = EquationOrder(K)
  A, mA = @inferred torsion_unit_group(M)
  @test order(A) == 2
  @test mA(A[1]) == M(-1)
  OK = maximal_order(K)
  A, mA = @inferred torsion_unit_group(OK)
  @test order(A) == 6
  @test isone(mA(A[1])^6)
  @test !isone(mA(A[1])^3)
  @test !isone(mA(A[1])^2)

  Kt, t = PolynomialRing(K, cached = false)
  Ls, gLs = number_field(t^2+1)
  G, mG = torsion_unit_group(Ls)
  @test ngens(G) == 1
  @test order(G) == 12
  @test torsion_units_order(Ls) == 12
  g = mG(G[1])
  @test g == torsion_units_generator(Ls)
  @test isone(g^12)
  @test !isone(g^4)
  @test !isone(g^3)

  Lns, gLns = number_field([t^2+1, t^2+2])
  G, mG = torsion_unit_group(Lns)
  @test ngens(G) == 1
  @test order(G) == 24
  @test torsion_units_order(Lns) == 24
  g = mG(G[1])
  @test g == torsion_units_generator(Lns)
  @test isone(g^24)
  @test !isone(g^8)
  @test !isone(g^3)
end
