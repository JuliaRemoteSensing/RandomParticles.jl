abstract type AbstractRegion end

"""
A sphere with radius `r`.
"""
Base.@kwdef struct SphereRegion <: AbstractRegion
    r::Float64
end

"""
A cylinder with radius `r` and half height `h`.
"""
Base.@kwdef struct CylinderRegion <: AbstractRegion
    r::Float64
    h::Float64
    periodic::Bool = false
end

"""
A box with half length `x`, `y` and `z`.
"""
Base.@kwdef struct BoxRegion <: AbstractRegion
    x::Float64
    y::Float64
    z::Float64
    periodic::NTuple{3,Bool} = (false, false, false)
end
