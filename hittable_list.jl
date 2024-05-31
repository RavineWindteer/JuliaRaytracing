include("hittable.jl")
include("interval.jl")
include("ray.jl")
include("sphere.jl")
include("utils.jl")
include("vec3.jl")


function hit!(
    rec_out::HitRecord,
    list::Array{Sphere}, r::Ray, ray_t::Interval)
    
    tempRec = HitRecord()
    hitAnything = false
    closestSoFar = Interval(ray_t.min, ray_t.max)

    @inbounds for sphere in list
        @inbounds if hit!(tempRec, sphere, r, closestSoFar)
            hitAnything = true
            closestSoFar.max = tempRec.t
            copy!(rec_out, tempRec)
        end
    end

    hitAnything
end
