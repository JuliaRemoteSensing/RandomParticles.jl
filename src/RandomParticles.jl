module RandomParticles

using GeometryBasics: Point3
using GLMakie: meshscatter
using Libdl: dlopen, dlclose, dlsym
using LinearAlgebra: norm
using Random: AbstractRNG, GLOBAL_RNG
using StructArrays: StructArray

include("region.jl")
include("particle.jl")
include("strategy.jl")
include("utils.jl")
include("MSTM_wrapper.jl")

rand_point(rng::AbstractRNG=GLOBAL_RNG) = 2.0 .* rand(rng, Point3) .- 1.0

struct NaiveSampling <: AbstractStrategy end

function sample(rng::AbstractRNG, sph::SphereRegion, radius::AbstractVector, ::NaiveSampling; max_retry_times::Integer=100)
    points = Vector{Float64}[]
    R = sph.r
    N = length(radius)

    for i = 1:N
        retry_times = 0
        ri = radius[i]

        new_point = rand_point(rng) .* (R - ri)
        while norm(new_point) > R - ri
            new_point = rand_point(rng) .* (R - ri)
        end
        min_dist = minimum(norm(point - new_point) - ri - rj for (point, rj) in zip(points, radius); init=Inf)
        while min_dist < 0 && retry_times < max_retry_times
            retry_times += 1
            new_point = rand_point(rng) .* (R - ri)
            while norm(new_point) > R - ri
                new_point = rand_point(rng) .* (R - ri)
            end
            min_dist = minimum(norm(point - new_point) - ri - rj for (point, rj) in zip(points, radius); init=Inf)
        end

        if min_dist >= 0
            push!(points, new_point)
        else
            error("Sampling failed")
        end
    end

    @info "Sampling succeeded using random sampling"

    return StructArray{SphereParticle}(([map(point -> point[i], points) for i in 1:3]..., radius))
end

sample(region, radius, strat; kwargs...) = sample(GLOBAL_RNG, region, radius, strat; kwargs...)

end
