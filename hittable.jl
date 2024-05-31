include("interval.jl")
include("material.jl")
include("ray.jl")
include("utils.jl")
include("vec3.jl")


mutable struct HitRecord
    frontFace::Bool
    t::FloatT
    p::Point3
    normal::Vec3
    mat::Material
    HitRecord(p::Point3, normal::Vec3, t::FloatT, mat::Material) =
        new(true, t, p, normal, mat)
    HitRecord(p::Point3, normal::Vec3, t::Real, mat::Material) =
        new(p, normal, FloatT(t), mat)
    HitRecord() = 
        new(true, 0.0, Point3(0.0, 0.0, 0.0), Vec3(0.0, 0.0, 0.0), Lambertian())
end

function copy!(dest_out::HitRecord, src::HitRecord)
    dest_out.frontFace = src.frontFace
    dest_out.t = src.t
    dest_out.p = src.p
    dest_out.normal = src.normal
    dest_out.mat = src.mat
    nothing
end

function set_face_normal!(rec_out::HitRecord, r::Ray, outwardNormal::Vec3)
    rec_out.frontFace = dot(r.direction, outwardNormal) < 0.0
    rec_out.normal = rec_out.frontFace ? outwardNormal : -outwardNormal
    nothing
end

function hit!(rec_out::HitRecord, any::Any, r::Ray, ray_t::Interval)
    println("hit! not implemented")
    false
end
