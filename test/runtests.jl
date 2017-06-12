using PDEOperators
using Base.Test
using FactCheck
using SpecialMatrices

context("Basic multiplication: ")do
    N = 100
    d_order = 2
    approx_order = 2
    x = collect(1:1.0:N).^2
    A = LinearOperator{Float64}(2,2,N)
    boundary_points = A.boundary_point_count

    res = A*x
    @test res[boundary_points + 1: N - boundary_points] == 2.0*ones(N - 2*boundary_points);

    N = 1000
    d_order = 4
    approx_order = 10
    y = collect(1:1.0:N).^4 - 2*collect(1:1.0:N).^3 + collect(1:1.0:N).^2;

    A = LinearOperator{Float64}(d_order,approx_order,N)
    boundary_points = A.boundary_point_count

    res = A*y
    @test_approx_eq_eps res[boundary_points + 1: N - boundary_points] 24.0*ones(N - 2*boundary_points) 10.0^-1; # Float64 is less stable

    A = LinearOperator{BigFloat}(d_order,approx_order,N)
    y = convert(Array{BigFloat, 1}, y)
    res = A*y
    @test_approx_eq_eps res[boundary_points + 1: N - boundary_points] 24.0*ones(N - 2*boundary_points) 10.0^-approx_order;
end
# y = convert(Array{Rational, 1}, y)
# res = A*y
# @test_approx_eq_eps res[boundary_points + 1: N - boundary_points] 24.0*ones(N - 2*boundary_points) 10.0^-approx_order;

# tests for full and sparse function
context("Full and Sparse functions")do
    N = 100
    d_order = 2
    approx_order = 2
    x = collect(1:1.0:N).^2

    A = LinearOperator{Float64}(d_order,approx_order,N)
    mat = full(A)
    sp_mat = sparse_full(A)
    @test mat == sp_mat;
    @test full(A, 10) == -Strang(10); # Strang Matrix is defined with the center term +ve
    @test full(A, N) == -Strang(N); # Strang Matrix is defined with the center term +ve
    @test full(A) == sp_mat

    # testing correctness
    N = 1000
    d_order = 4
    approx_order = 10
    y = collect(1:1.0:N).^4 - 2*collect(1:1.0:N).^3 + collect(1:1.0:N).^2;
    y = convert(Array{BigFloat, 1}, y)

    A = LinearOperator{BigFloat}(d_order,approx_order,N)
    boundary_points = A.boundary_point_count
    mat = full(A, N)
    sp_mat = sparse_full(A)
    @test mat == sp_mat

    res = A*y
    @test_approx_eq_eps res[boundary_points + 1: N - boundary_points] 24.0*ones(N - 2*boundary_points) 10.0^-approx_order;
    @time @test_approx_eq_eps A*y mat*y 10.0^-approx_order;
    @time @test_approx_eq_eps A*y sp_mat*y 10.0^-approx_order;
    @time @test_approx_eq_eps sp_mat*y mat*y 10.0^-approx_order;
end

context("Indexing tests")do
    N = 1000
    d_order = 4
    approx_order = 10

    A = LinearOperator{Float64}(d_order,approx_order,N)
    @test_approx_eq_eps A[1,1] 13.717407 1e-4
    @test A[:,1] == (full(A))[:,1]
    @test A[10,20] == 0

    for i in 1:N
        @test A[i,i] == A.stencil_coefs[div(A.stencil_length, 2) + 1]
    end

    # Indexing Tests
    N = 1000
    d_order = 2
    approx_order = 2

    A = LinearOperator{Float64}(d_order,approx_order,N)
    M = full(A)

    @test A[1,1] == -2.0
    @test A[1:4,1] == M[1:4,1]
    @test A[5,2:10] == M[5,2:10]
    @test A[60:100,500:600] == M[60:100,500:600]
end

println("ALL TESTS PASSED!")