include("hittable.jl")
include("material.jl")
include("ray.jl")
include("vec3.jl")


function scatter!(
    attenuation_out::Color, scattered_out::Ray,
    mat::Lambertian, r_in::Ray, rec::HitRecord)

    scatter_direction = rec.normal + random_unit_vector()

    # Catch degenerate scatter direction
    if near_zero(scatter_direction)
        scatter_direction = rec.normal
    end

    copy!(scattered_out, Ray(rec.p, scatter_direction))
    copy!(attenuation_out, mat.albedo)
    true
end

function scatter!(
    attenuation_out::Color, scattered_out::Ray,
    mat::Metal, r_in::Ray, rec::HitRecord)

    reflected = reflect(unit_vector(r_in.direction), rec.normal)
    reflected = unit_vector(reflected) + (mat.fuzz * random_unit_vector())
    copy!(scattered_out, Ray(rec.p, reflected))
    copy!(attenuation_out, mat.albedo)
    (dot(scattered_out.direction, rec.normal) > 0)
end

function scatter!(
    attenuation_out::Color, scattered_out::Ray,
    mat::Dielectric, r_in::Ray, rec::HitRecord)

    copy!(attenuation_out, Color(1.0, 1.0, 1.0))
    ri = rec.frontFace ? (1.0/mat.refraction_index) : mat.refraction_index

    unit_direction = unit_vector(r_in.direction)
    cos_theta = min(dot(-unit_direction, rec.normal), 1.0)
    sin_theta = sqrt(1.0 - cos_theta*cos_theta)

    cannot_refract = (ri * sin_theta > 1.0)
    
    if cannot_refract || (reflectance(cos_theta, ri) > random_float())
        direction = reflect(unit_direction, rec.normal)
    else
        direction = refract(unit_direction, rec.normal, ri)
    end

    copy!(scattered_out, Ray(rec.p, direction))
    true
end

function reflectance(cosine::FloatT, refraction_index::FloatT)
    # Use Schlick's approximation for reflectance.
    r0 = (1.0 - refraction_index) / (1.0 + refraction_index)
    r0 = r0 * r0
    r0 + (1.0 - r0) * (1.0 - cosine)^5
end
reflectance(cosine::Real, refraction_index::Real) =
    reflectance(FloatT(cosine), FloatT(refraction_index))
