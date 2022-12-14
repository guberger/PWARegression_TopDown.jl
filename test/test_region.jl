using LinearAlgebra
using JuMP
using HiGHS
using Test
@static if isdefined(Main, :TestLocal)
    include("../src/PWARegression.jl")
else
    using PWARegression
end
PWAR = PWARegression

solver() = Model(optimizer_with_attributes(
    HiGHS.Optimizer, "output_flag"=>false
))

NT = PWAR.Node{Vector{Float64},Float64}
nodes = NT[]
aref1 = [1, 2, 1]
aref2 = [0, 2, 2]
for xt in Iterators.product(0:0.2:1, 0:0.4:2)
    local x = vcat(collect(xt), 1.0)
    local η = xt[1] > 0.5 ? dot(aref1, x) : dot(aref2, x)
    push!(nodes, PWAR.Node(x, η))
end

ϵ = 0.1
BD = 100
β = 1e-8
γ = 0.01
σ = 0.2
δ = 1e-5
inodes_list = PWAR.optimal_covering(
    nodes, ϵ, BD, γ, δ, 3, solver, solver, solver
)

inodes_covered = BitSet()
for inodes in inodes_list
    union!(inodes_covered, inodes)
end

@testset "optimal_covering" begin
    @test inodes_covered == BitSet(1:length(nodes))
end