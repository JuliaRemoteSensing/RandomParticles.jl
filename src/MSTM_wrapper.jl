Base.@kwdef struct MSTMSampling <: AbstractStrategy
    max_collisions_per_sphere::Int32 = 3
    max_number_time_steps::Int32 = 10000
end

const LIBMSTM = joinpath(@__DIR__, "..", "shared", "librsgen.so")

mstmshape(::SphereRegion) = 2
mstmdim(sph::SphereRegion) = fill(sph.r, 3)
mstmpc(::SphereRegion) = fill(false, 3)

mstmshape(::CylinderRegion) = 1
mstmdim(cyl::CylinderRegion) = [cyl.r, cyl.r, cyl.h]
mstmpc(cyl::CylinderRegion) = [false, false, cyl.periodic]

mstmshape(::BoxRegion) = 0
mstmdim(box::BoxRegion) = [box.x, box.y, box.z]
mstmpc(box::BoxRegion) = vcat(box.periodic...)

function mstmpsdsamp(σ, rmax, n::Integer)
    radius = Float64[]

    dlopen(LIBMSTM) do libmstm
        for _ in 1:n
            x = Ref{Float64}()
            ccall(
                dlsym(libmstm, :__random_sphere_configuration_MOD_psdsamp),
                Cvoid,
                (
                    Ref{Float64},
                    Ref{Float64},
                    Ref{Float64},
                ),
                σ, rmax, x
            )
            push!(radius, x[])
        end
    end

    return radius
end

function sample(region::AbstractRegion, radius::AbstractVector, strategy::MSTMSampling)
    dlopen(LIBMSTM) do libmstm
        N = length(radius)
        pos = zeros(3, N)

        function _setglobal(sym::Symbol, typ::DataType, len::Integer, val)
            ptr = cglobal(dlsym(libmstm, sym), typ)
            unsafe_wrap(Vector{typ}, convert(Ptr{typ}, ptr), (len,)) .= val
        end

        _setglobal(:__random_sphere_configuration_MOD_target_shape, Int32, 1, mstmshape(region))
        _setglobal(:__random_sphere_configuration_MOD_target_dimensions, Float64, 3, mstmdim(region))
        _setglobal(:__random_sphere_configuration_MOD_max_collisions_per_sphere, Int32, 1, strategy.max_collisions_per_sphere)
        _setglobal(:__random_sphere_configuration_MOD_periodic_bc, Int32, 3, mstmpc(region))

        status = Ref{Int32}()

        ccall(
            dlsym(libmstm, :__random_sphere_configuration_MOD_random_cluster_of_spheres),
            Cvoid,
            (
                Ref{Int32},
                Ptr{Float64},
                Ptr{Float64},
                Ref{Int32},
                Ref{Int32},
                Ref{Int32},
            ),
            N,
            pos,
            radius,
            0,
            status,
            strategy.max_number_time_steps,
        )

        if status[] == 3
            error("Sampling failed")
        elseif status[] == 0
            @info "Sampling succeeded using random sampling"
        elseif status[] == 1
            @info "Sampling succeeded using layered sampling + diffusion"
        else
            @info "Sampling succeeded using initial HCP + diffusion"
        end

        spheres = StructArray{SphereParticle}((pos[1, :], pos[2, :], pos[3, :], radius))

        @debug for i in 1:N
            if spheres[i] ∉ region
                error("Particle outside region")
            end

            for j in i+1:N
                if overlap(spheres[i], spheres[j])
                    error("Sampling Error")
                end
            end
        end

        return spheres
    end
end
