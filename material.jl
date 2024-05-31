include("utils.jl")
include("vec3.jl")


abstract type Material end

struct Lambertian <: Material
    albedo::Color
    Lambertian(albedo::Color) = new(albedo)
    Lambertian() = new(Color(0.0, 0.0, 0.0))
end

struct Metal <: Material
    fuzz::FloatT
    albedo::Color
    Metal(albedo::Color, fuzz::FloatT) = new(fuzz, albedo)
    Metal(albedo::Color, fuzz::Real) = new(FloatT(fuzz), albedo)
    Metal() = new(0.0, Color(0.0, 0.0, 0.0))
end

struct Dielectric <: Material
    refraction_index::FloatT
    Dielectric(refraction_index::FloatT) = new(refraction_index)
    Dielectric(refraction_index::Real) = new(FloatT(refraction_index))
    Dielectric() = new(1.0)
end
