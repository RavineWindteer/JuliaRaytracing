include("hittable.jl")
include("material.jl")
include("ray.jl")
include("utils.jl")
include("vec3.jl")


struct Sphere
    radius::FloatT
    center::Point3
    mat::Material
    Sphere(center::Point3, radius::FloatT, mat::Material) =
        new(radius, center, mat)
    Sphere(center::Point3, radius::Real, mat::Material) =
        new(FloatT(radius), center, mat)
end

function hit!(
    rec_out::HitRecord,
    sphere::Sphere, r::Ray, ray_t::Interval)

    oc = sphere.center - r.origin
    a = length_squared(r.direction)
    h = dot(r.direction, oc)
    c = length_squared(oc) - sphere.radius*sphere.radius

    discriminant = h*h - a*c
    if discriminant < 0
        return false
    end

    sqrtd = sqrt(discriminant)

    # Find the nearest root that lies in the acceptable range.
    root = (h - sqrtd) / a
    if !surrounds(ray_t, root)
        root = (h + sqrtd) / a
        if !surrounds(ray_t, root)
            return false
        end
    end

    rec_out.t = root
    rec_out.p = at(r, rec_out.t)
    outwardNormal = (rec_out.p - sphere.center) / sphere.radius
    set_face_normal!(rec_out, r, outwardNormal)
    rec_out.mat = sphere.mat

    true
end
