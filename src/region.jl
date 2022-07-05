abstract type AbstractRegion end

"""
A sphere with radius `r`.
"""
struct SphereRegion <: AbstractRegion
    r::Float64
end

"""
A cylinder with radius `r` and half height `h`.
"""
struct CylinderRegion <: AbstractRegion
    r::Float64
    h::Float64
end

"""
A box with half length `x`, `y` and `z`.
"""
struct BoxRegion <: AbstractRegion
    x::Float64
    y::Float64
    z::Float64
end
