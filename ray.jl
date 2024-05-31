include("vec3.jl")


mutable struct Ray
    origin::Point3
    direction::Vec3
    Ray(origin::Point3, direction::Vec3) = new(origin, direction)
    Ray() = new(Point3(0.0, 0.0, 0.0), Vec3(0.0, 0.0, 0.0))
end

at(r::Ray, t::Real) = r.origin + t*r.direction

function copy!(dest_out::Ray, src::Ray)
    dest_out.origin = src.origin
    dest_out.direction = src.direction
    nothing
end
