const default_h_kwargs = Dict{Symbol, Any}()

"""
    set_default(; kwargs...)

Set default kwarg values for handcalcs. 

This works for all keyword arguments. It is additive such that if
you call it multiple times, defaults will be added or replaced, but not reset.

## Kwargs
- `cols`: sets the number of columns in the output
- `spa`: sets the line spacing
- `len`: can set to `:long` and it will split equation to multiple lines
- `color`: change the color of the output (`:blue`, `:red`, etc)
- `precision`: formats numbers to a max precision. Given `precision = 2`, `2.567` will show as `2.57`, while `2.5` would show as `2.5`
- `h_env`: choose between "aligned" (default), "align" and other LaTeX options
- `not_funcs`: name the functions you do not want to "unroll" 
- `parse_pipe`: a boolean value (default=true) to remove pipe from equation. This is intended for unitful equations.
- `disable`: disable handcalcs rendering to run simulations and turn it back on when needed.

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
    get_handcalcs()

Get a Dict with the user-specified default kwargs for handcalcs, set by `set_handcalcs`.

## Kwargs
- `cols`: sets the number of columns in the output
- `spa`: sets the line spacing
- `len`: can set to `:long` and it will split equation to multiple lines
- `h_env`: Choose between "aligned" (default), "align" and other LaTeX options
- `precision`: formats numbers to a max precision. Given `precision = 2`, `2.567` will show as `2.57`, while `2.5` would show as `2.5`
- `not_funcs`: Name the functions you do not want to "unroll" 
- `parse_pipe`: a boolean value (default=true) to remove pipe from equation. This is intended for unitful equations.
- `disable`: disable handcalcs rendering to run simulations and turn it back on when needed.
"""
function get_handcalcs end
get_handcalcs() = default_h_kwargs
get_handcalcs(arg::Symbol) = default_h_kwargs[arg]
get_handcalcs(args::AbstractArray) =  map(x->default_h_kwargs[x], args)
get_handcalcs(args...) = Tuple(get_handcalcs(arg) for arg in args)
