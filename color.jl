include("interval.jl")
include("utils.jl")
include("vec3.jl")


if !isdefined(Main, :_color_jl)
    const _color_jl = true
    
    const intensity = Interval(0.000, 0.999)
end

@inline linear_to_gamma(x::FloatT) = (x > 0.0) ? sqrt(x) : 0.0
@inline linear_to_gamma(x::Real) = linear_to_gamma(FloatT(x))

function write_color(io::IO, pixel_color::Vec3)
    rbyte = trunc(Int32,
        255.999 * clamp(intensity, linear_to_gamma(pixel_color.x)))
    gbyte = trunc(Int32,
        255.999 * clamp(intensity, linear_to_gamma(pixel_color.y)))
    bbyte = trunc(Int32,
        255.999 * clamp(intensity, linear_to_gamma(pixel_color.z)))

    write(io, "$(rbyte) $(gbyte) $(bbyte)\n")
end
