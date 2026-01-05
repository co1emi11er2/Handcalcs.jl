import Latexify

precision_format(precision::Integer) = x -> string(round(x, RoundNearestTiesAway, digits=precision))

struct PrecisionNumberFormatter <: AbstractNumberFormatter
    precision::Integer
    f::Function

    PrecisionNumberFormatter(precision::Integer) = new(precision, precision_format(precision))
end

(f::PrecisionNumberFormatter)(x::Real) = f.f(x)

(f::PrecisionNumberFormatter)(x::Integer) = string(x)

(f::PrecisionNumberFormatter)(x::Bool) = string(x)



