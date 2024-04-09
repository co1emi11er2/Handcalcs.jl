const default_h_kwargs = Dict{Symbol, Any}()

"""
    set_default(; kwargs...)

Set default kwarg values for handcalcs. 

This works for all keyword arguments. It is additive such that if
you call it multiple times, defaults will be added or replaced, but not reset.

Example: 
```julia
set_handcalcs(cols = 2, spa = 5)
```

To reset the defaults that you have set, use `reset_handcalcs`.
To see your specified defaults, use `get_handcalcs`.
"""
function set_handcalcs(; kwargs...)
    for key in keys(kwargs)
        default_h_kwargs[key] = kwargs[key]
    end
end

"""
    reset_handcalcs()

Reset user-specified default kwargs for handcalcs, set by `set_handcalcs`.
"""
reset_handcalcs() = empty!(default_h_kwargs)

"""
    get_handcalcs

Get a Dict with the user-specified default kwargs for handcalcs, set by `set_handcalcs`.
"""
function get_handcalcs end
get_handcalcs() = default_h_kwargs
get_handcalcs(arg::Symbol) = default_h_kwargs[arg]
get_handcalcs(args::AbstractArray) =  map(x->default_h_kwargs[x], args)
get_handcalcs(args...) = Tuple(get_handcalcs(arg) for arg in args)