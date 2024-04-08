
"""
    @handcalcs expressions

Create `LaTeXString` representing `expressions`. The expressions representing a number of expressions.
A single expression being a vaiable followed by an equals sign and an algebraic equation.
Any side effects of the expression, like assignments, are evaluated as well.  
The RHS can be formatted or otherwise transformed by supplying a function as kwarg `post`.
Can also add comments to the end of equations. See example below.

# Examples
```julia-repl
julia> a = 2
2
julia> b = 5
5
julia> @handcalcs begin 
    c = a + b; "eq 1";
    d = a - c
end
L"\$\\begin{align}
c &= a + b = 2 + 5 = 7\\text{  }(\\text{eq 1})
\\\\[10pt]
d &= a - c = 2 - 7 = -5
\\end{align}\$"

julia> c
7
julia> d
-5

```
"""
macro handcalcs(expr, kwargs...)
    expr = unblock(expr)
	expr = rmlines(expr)
    exprs = []
    # If singular expression
    if expr.head == :(=)
        push!(exprs, :(@handcalc $(expr) $(kwargs...)))
        return Expr(:block, esc(Expr(:call, :multiline_latex, exprs...)))
    end
    h_kwargs, kwargs = clean_kwargs(kwargs)
    # If multiple Expressions
    for arg in expr.args
        if typeof(arg) == String # type string will be converted to a comment
            comment = latexstring("\\;\\text{  }(\\text{", arg, "})")
            push!(exprs, comment)
		elseif typeof(arg) == Expr # type expression will be latexified
            push!(exprs, :(@handcalc $(arg) $(kwargs...)))
		else
			error("Code pieces should be of type string or expression")
        end
    end
    return Expr(:block, esc(Expr(:call, :multiline_latex, Expr(:parameters, _extractparam.(h_kwargs)...), exprs...)))
end

function multiline_latex(exprs...; cols=1, spa=10, kwargs...)
    cols_start = cols
    multi_latex = "\\begin{align*}"
    for (i, expr) in enumerate(exprs)
        if occursin("text{  }", expr)
            multi_latex *= expr[2:end-1] # remove the $ from end and beginning of string
        else
            cleaned_expr = clean_expr(expr)
            if cols == 0 
                cols = cols_start 
                multi_latex *= "\n" * (i ==1 ? "" : "\\\\[$spa" * "pt]\n") * cleaned_expr
            else
                multi_latex *= (i ==1 ? "\n" : "&\n") * cleaned_expr 
            end
            cols -= 1
        end
    end
    multi_latex *= "\n" * "\\end{align*}"
    return LaTeXString(multi_latex)
end

function clean_expr(expr)
    expr = expr[2:end-1] # remove the $ from end and beginning of string
    expr = expr[end] == " " ? expr : expr * " " # add trailing space if there isn't one
    expr = split(expr, "=") |> unique |> x -> join(x, "=")[1:end-1] # removes any redundant parts, and removes space at the end
    expr = replace(expr, "="=>"&=", count=1) # add alignment
end

function clean_kwargs(kwargs)
    h_kwargs = []
    l_kwargs = []
    for kwarg in kwargs
        if _split_kwarg(kwarg) in h_syms
            h_kwargs = push!(h_kwargs, kwarg)
        else
            l_kwargs = push!(l_kwargs, kwarg)
        end
    end
    return Tuple(h_kwargs), Tuple(l_kwargs)
end

_split_kwarg(arg::Symbol) = arg
_split_kwarg(arg::Expr) = arg.args[1]