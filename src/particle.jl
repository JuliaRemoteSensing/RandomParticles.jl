struct SphereParticle{T<:AbstractFloat}
    x::T
    y::T
    z::T
    r::T
end

dist(sph1::SphereParticle, sph2::SphereParticle) = norm((sph1.x - sph2.x, sph1.y - sph2.y, sph1.z - sph2.z)) - sph1.r - sph2.r

overlap(sph1::SphereParticle, sph2::SphereParticle) = dist(sph1, sph2) < 0.0

Base.:(∈)(sph::SphereParticle, region::SphereRegion) = norm((sph.x, sph.y, sph.z)) + sph.r <= region.r

Base.:(∈)(sph::SphereParticle, region::CylinderRegion) = sph.z + sph.r <= region.h && sph.z - sph.r >= -region.h && norm((sph.x, sph.y)) + sph.r <= region.r

Base.:(∈)(sph::SphereParticle, region::BoxRegion) = sph.x + sph.r <= region.x && sph.x - sph.r >= -region.x && sph.y + sph.r <= region.y && sph.y - sph.r >= -region.y && sph.z + sph.r <= region.z && sph.z - sph.r >= -region.z
