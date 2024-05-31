include("utils.jl")


mutable struct Vec3
    x::FloatT
    y::FloatT
    z::FloatT
    Vec3(x::FloatT, y::FloatT, z::FloatT) = new(x, y, z)
    Vec3(x::Real, y::Real, z::Real) = Vec3(FloatT(x), FloatT(y), FloatT(z))
    Vec3() = new(0.0, 0.0, 0.0)
end

function Base.getindex(v::Vec3, i::Int)
    @assert 1 <= i <= 3 (
        "Index out of bounds: valid indices for Vec3 are 1, 2, and 3.")
    unsafe_load(Ptr{FloatT}(UInt(Base.pointer_from_objref(v))), i)
end

Base.:-(v::Vec3) = Vec3(-v.x, -v.y, -v.z)
Base.:+(a::Vec3,b::Vec3) = Vec3(a.x+b.x, a.y+b.y, a.z+b.z)
Base.:-(a::Vec3,b::Vec3) = Vec3(a.x-b.x, a.y-b.y, a.z-b.z)
Base.:*(a::Vec3,b::Vec3) = Vec3(a.x*b.x, a.y*b.y, a.z*b.z)
Base.:*(a::Vec3,b::Vec3) = Vec3(a.x*b.x, a.y*b.y, a.z*b.z)
Base.:*(t::FloatT,v::Vec3) = Vec3(t*v.x, t*v.y, t*v.z)
Base.:*(v::Vec3,t::FloatT) = t*v
Base.:*(t::Real,v::Vec3) = FloatT(t)*v
Base.:*(v::Vec3,t::Real) = FloatT(t)*v
Base.:/(v::Vec3,t::FloatT) = (1.0/t)*v
Base.:/(v::Vec3,t::Real) = v/FloatT(t)

function copy!(dest_out::Vec3, src::Vec3)
    dest_out.x = src.x
    dest_out.y = src.y
    dest_out.z = src.z
    nothing
end

length_squared(v::Vec3) = v.x*v.x + v.y*v.y + v.z*v.z
length(v::Vec3) = sqrt(length_squared(v))
near_zero(v::Vec3) = (abs(v.x) < 1e-8) && (abs(v.y) < 1e-8) && (abs(v.z) < 1e-8)
dot(u::Vec3, v::Vec3) = u.x*v.x + u.y*v.y + u.z*v.z
cross(u::Vec3, v::Vec3) =
    Vec3(u.y*v.z - u.z*v.y, u.z*v.x - u.x*v.z, u.x*v.y - u.y*v.x)
unit_vector(v::Vec3) = v / length(v)
random() = Vec3(random_float(), random_float(), random_float())
random(min::FloatT, max::FloatT) = Vec3(random_float(min, max),
    random_float(min, max), random_float(min, max))
random(min::Real, max::Real) = random(FloatT(min), FloatT(max))

function Base.show(io::IO, v::Vec3)
    print(io, "$(v.x) $(v.y) $(v.z)")
end

if !isdefined(Main, :_vec3_jl)
    const _vec3_jl = true

    const Point3 = Vec3
    const Color = Vec3
end

function random_in_unit_sphere()
    while true
        p = random(-1.0, 1.0)
        if length_squared(p) < 1.0
            return p
        end
    end
end

random_unit_vector() = unit_vector(random_in_unit_sphere())

function random_on_hemisphere(normal::Vec3)
    on_unit_sphere = random_unit_vector()
    if dot(on_unit_sphere, normal) > 0.0 # In the same hemisphere as the normal
        return on_unit_sphere
    end
    -on_unit_sphere
end

function random_in_unit_disk()
    while true
        p = Vec3(random_float(-1.0, 1.0), random_float(-1.0, 1.0), 0.0)
        if length_squared(p) < 1.0
            return p
        end
    end
end

reflect(v::Vec3, n::Vec3) = v - 2.0*dot(v, n)*n

function refract(uv::Vec3, n::Vec3, etai_over_etat::FloatT)
    cos_theta = min(dot(-uv, n), 1.0)
    r_out_perp = etai_over_etat * (uv + cos_theta*n)
    r_out_parallel = -sqrt(abs(1.0 - length_squared(r_out_perp))) * n
    (r_out_perp + r_out_parallel)
end
