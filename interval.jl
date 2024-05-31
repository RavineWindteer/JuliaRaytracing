include("utils.jl")


mutable struct Interval
    min::FloatT
    max::FloatT
    Interval(min::FloatT, max::FloatT) = new(min, max)
    Interval(min::Real, max::Real) = Interval(FloatT(min), FloatT(max))
    Interval() = new(+infinity, -infinity) # Deafult interval is empty
end

size(i::Interval) = i.max - i.min
contains(i::Interval, x::FloatT) = i.min <= x <= i.max
contains(i::Interval, x::Real) = contains(i, FloatT(x))
surrounds(i::Interval, x::FloatT) = i.min < x < i.max
surrounds(i::Interval, x::Real) = surrounds(i, FloatT(x))

function clamp(i::Interval, x::FloatT)
    if (x < i.min) return i.min end
    if (x > i.max) return i.max end
    x
end
clamp(i::Interval, x::Real) = clamp(i, FloatT(x))

if !isdefined(Main, :_interval_jl)
    const _interval_jl = true
    
    const empty = Interval(+infinity, -infinity)
    const universe = Interval(-infinity, +infinity)
end
