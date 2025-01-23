import Latexify

precision_format(precision::Integer) = x -> Latexify.Format.format(round(x, RoundNearestTiesAway, digits=precision))

struct PrecisionNumberFormatter <: AbstractNumberFormatter
    precision::Integer
    f::Function

    PrecisionNumberFormatter(precision::Integer) = new(precision, precision_format(precision))
end

(f::PrecisionNumberFormatter)(x::Real) = f.f(x)

(f::PrecisionNumberFormatter)(x::Bool) = string(x)



