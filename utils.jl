if !isdefined(Main, :_utils_jl)
    const _utils_jl = true

    const FloatT = Float64

    const infinity = FloatT(Inf)
    const pi = FloatT(π)
end

function degrees_to_radians(degrees::FloatT)
    degrees * pi / 180.0
end

degrees_to_radians(degrees::Real) = degrees_to_radians(FloatT(degrees))

random_float() = rand(FloatT)
random_float(min::FloatT, max::FloatT) = min + (max - min) * random_float()
random_float(min::Real, max::Real) = random_float(FloatT(min), FloatT(max))
