
"""
    @handcalcs(expressions, kwargs)

Create `LaTeXString` representing `expressions`. The expressions representing a number of
expressions. A single expression being a vaiable followed by an equals sign and an algebraic
equation. Any side effects of the expression, like assignments, are evaluated as well.  
The RHS can be formatted or otherwise transformed by supplying a function as kwarg `post`.
Can also add comments to the end of equations. See example below.

## Kwargs
- cols: sets the number of columns in the output
- spa: sets the line spacing
- len: can set to `:long` and it will split equation to multiple lines
- color: change the color of the output (`:blue`, `:red`, etc)
- h_env: choose between "aligned" (default), "align" and other LaTeX options
- not_funcs: name the functions you do not want to "unroll" 

# Examples
```julia-repl
julia> a = 2
2

julia> b = 5
5

julia> e = 7
7

julia> @handcalcs begin 
    c = a + b; "eq 1";
    d = a - c
    e
end
L"\$\\begin{aligned}
c &= a + b = 2 + 5 = 7\\;\\text{  }(\\text{eq 1})
\\\\[10pt]
d &= a - c = 2 - 7 = -5
\\\\[10pt]
e &= 7
\\end{aligned}\$"

julia> c
7

julia> d
-5

```
"""
macro handcalcs(expr, kwargs...)
    if get(default_h_kwargs, :disable, false)
        return esc(expr)
    end

    expr = unblock(expr)
	expr = rmlines(expr)
    is_recursive, h_kwargs, kwargs = clean_kwargs(kwargs) # parse handcalc kwargs (h_kwargs)
    exprs = [] #initialize expression accumulator

    # If singular symbol
    if typeof(expr) == Symbol
        push!(exprs, :(@latexdefine $(expr) $(kwargs...)))
        return is_recursive ? _handcalcs_recursive(exprs) : _handcalcs(exprs, h_kwargs)
    end

    # If singular expression
    if expr.head == :(=) || expr.head == :call
        push!(exprs, :(@handcalc $(expr) $(kwargs...)))
        return is_recursive ? _handcalcs_recursive(exprs) : _handcalcs(exprs, h_kwargs)
    end
    
    # If multiple Expressions
    for arg in expr.args
        if typeof(arg) == String # type string will be converted to a comment
            comment = latexstring("\\;\\text{  }(\\text{", arg, "})")
            push!(exprs, comment)
		elseif typeof(arg) == Expr # type expression will be latexified
            push!(exprs, :(@handcalc $(arg) $(kwargs...)))
        elseif typeof(arg) == Symbol # type symbol is a parameter that will be returned back
            push!(exprs, :(@latexdefine $(arg) $(kwargs...)))
		else
			error("Code pieces should be of type string or expression")
        end
    end
    return is_recursive ? _handcalcs_recursive(exprs) : _handcalcs(exprs, h_kwargs)
end

function _handcalcs(exprs, h_kwargs)
    Expr(:block, esc(
        Expr(:call, :multiline_latex, 
        Expr(:parameters, _extractparam.(h_kwargs)...), exprs...)))
end

function _handcalcs_recursive(exprs)
    Expr(:block, esc(
        Expr(:call, :collect_exprs, 
        exprs...)))
end

function collect_exprs(exprs...) # just collect when exprs recursive
    exprs_array = []
    for expr in exprs
        push!(exprs_array, expr)
    end
    return exprs_array
end

function multiline_latex(exprs...; kwargs...)
    h_kwargs = merge(default_h_kwargs, kwargs)
    return process_multiline_latex(exprs...;h_kwargs...)
end

function clean_expr(expr, len, spa)
    expr = expr[2:end-1] # remove the $ from end and beginning of string
    expr = expr[end] == " " ? expr : expr * " " # add trailing space if there isn't one
    
    # if format pattern
    pattern = r"\\begin\{cases\}(.*?)\\end\{cases\}"s 
    m = match(pattern, expr)
    if !isnothing(m) # expr is an if statement, do something different

        # change "=" within ifs to "==" so they do not match to below exprs
        for m in eachmatch(pattern, expr) 
            new_m = replace(m.match, "=" => "==")
            expr = replace(expr, m.match => new_m)
        end

        expr = split(expr, " = ") |> unique |> x -> join(x, " = ")[1:end-1] # removes any redundant parts, and removes space at the end
        expr = replace(expr, " = "=>" &= ", count=1) # add alignment
        expr = len == :long ? replace(expr, " = "=>"\n\\\\[$spa" *"pt]\n&= ", count=2) : expr

        # change "==" back to "="
        for m in eachmatch(pattern, expr) 
            new_m = replace(m.match, "==" => "=")
            expr = replace(expr, m.match => new_m)
        end
        return expr
    end

    expr = split(expr, "=") |> unique |> x -> join(x, "=")[1:end-1] # removes any redundant parts, and removes space at the end
    expr = replace(expr, "="=>"&=", count=1) # add alignment
    expr = len == :long ? replace(expr, " ="=>"\n\\\\[$spa" *"pt]\n&=", count=2) : expr
end

# Splits handcalc kwargs and latexify kwargs 
# Also checks for recursion (if @handcalcs is being called from @handcalc)
function clean_kwargs(kwargs) 
    is_recursive = false
    h_kwargs = []
    l_kwargs = []
    for kwarg in kwargs
        split_kwarg = _split_kwarg(kwarg)
        if split_kwarg in h_syms
            h_kwargs = push!(h_kwargs, kwarg)
        elseif split_kwarg == :is_recursive
            is_recursive = true
        else
            l_kwargs = push!(l_kwargs, kwarg)
        end
    end
    return is_recursive, Tuple(h_kwargs), Tuple(l_kwargs)
end

_split_kwarg(arg::Symbol) = arg
_split_kwarg(arg::Expr) = arg.args[1]

function process_multiline_latex(
    exprs...;
    cols=1, 
    spa=10, 
    h_env="aligned",
    len = :short, 
    color = :black,
    kwargs...
    )
    cols = len == :long ? 1 : cols
    exprs = collect(Leaves(exprs)) # This handles nested vectors when recursive
    cols_start = cols
    multi_latex = "\\begin{$h_env}"
    for (i, expr) in enumerate(exprs)
        if occursin("text{  }", expr)
            multi_latex *= expr[2:end-1] # remove the $ from end and beginning of string
        else
            cleaned_expr = clean_expr(expr, len, spa)
            if cols == 0 
                cols = cols_start 
                multi_latex *= "\n" * (i ==1 ? "" : "\\\\[$spa" * "pt]\n") * cleaned_expr
            else
                multi_latex *= (i ==1 ? "\n" : "&\n") * cleaned_expr 
            end
            cols -= 1
        end
    end
    multi_latex *= "\n" * "\\end{$h_env}"
    if color != :black
        color = string(color)
        multi_latex = "\\color{$color} "* multi_latex 
    end
    return h_env == "aligned" ? latexstring(multi_latex) : LaTeXString(multi_latex)
end