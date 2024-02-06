"""
Module for better calc documentation.
"""
module Handcalcs

using Latexify: latexify
using MacroTools: postwalk
using MacroTools
using LaTeXStrings
# using CodeTracking, Revise

export @handcalc, @handcalcs, latexify, multiline_latex, calc_Ix, @handfunc

# TODO: need to rewrite handcalc to fix unitful issue
"""
    @handcalc expression

Create `LaTeXString` representing `expression`. The expression being a vaiable followed by an equals sign and an algebraic equation.
Any side effects of the expression, like assignments, are evaluated as well.
The RHS can be formatted or otherwise transformed by supplying a function as kwarg `post`.

# Examples
```julia-repl
julia> a = 2
2
julia> b = 5
5
julia> @handcalc c = a + b
L"\$c = a + b = 2 + 5 = 7\$"

julia> c
7
```
"""
macro handcalc(expr, kwargs...)
    expr = unblock(expr)
	expr = rmlines(expr)
    math_syms = [:*, :/, :^, :+, :-, :%, :.*, :./, :.^, :.+, :.-, :.%]
    expr_numeric = postwalk(x -> (x isa Symbol) & (x ∉ math_syms) ? numeric_sub(x) : x, expr.args[2:end]...)
    params = _extractparam.(kwargs)
    post = :identity
    for param in params
        if param === :post
            post = :post
            break
        end
        if param isa Expr && param.args[1] === :post
            post = param.args[2]
            break
        end
    end
    return esc(
        Expr(
            :call,
            :latexify,
            Expr(:parameters, _extractparam.(kwargs)...),
            Expr(:call, :Expr, QuoteNode(:(=)), Meta.quot(expr), Expr(:call, :Expr, QuoteNode(:(=)), Meta.quot(expr_numeric), Expr(:call, post, _executable(expr)))),
        ),
    )
end

function _executable(expr)
    return postwalk(expr) do ex
        if Meta.isexpr(ex, :$)
            return ex.args[1]
        end
        return ex
    end
end

_extractparam(arg::Symbol) = arg
_extractparam(arg::Expr) = Expr(:kw, arg.args[1], arg.args[2]) 

function numeric_sub(x)
	try Expr(:($), x)
	catch
		x
	end
end

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
    c = a + b; "eq 1"
    d = a - c
end
L"\$\begin{align}
\\\\c &= a + b = 2 + 5 = 7\\text{  }(\\text{eq 1})
\\\\d &= a - c = 2 - 7 = -5
\end{align}\$"

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
    for arg in expr.args
        if typeof(arg) == String # type string will be converted to a comment
            comment = latexstring("(\\text{", arg, "})")
            push!(exprs, comment)
		elseif typeof(arg) == Expr # type expression will be latexified
            push!(exprs, :(@handcalc $(arg)))
		else
			error("Code pieces should be of type string or expression")
        end
    end
    return Expr(:block, esc(expr), esc(Expr(:call, :multiline_latex, exprs...)))
end

function multiline_latex(exprs...)
    multi_latex = L"\begin{align}"[1:end-1] # remove the $ from end of string
    for expr in exprs
        if occursin("text", expr)
            multi_latex *= "\\text{  }" * expr[2:end-1] # remove the $ from end and beginning of string
        else
            multi_latex *=  "\n" * "\\\\" * replace(expr[2:end-1], "="=>"&=", count=1) # remove the $ from end and beginning of string
        end
    end
    multi_latex *= "\n" * L"\end{align}"[2:end] # remove the $ from beginning of string
    return latexstring(multi_latex)
end

function calc_Ix(b, h) 
	return b*h^3/12;
end

# TODO: Write macro that will parse a function
macro handfunc(expr, kwargs...)
    expr = unblock(expr)
	expr = rmlines(expr)
    exprs = []
    println(expr)
    # @show($(expr.args[2]))
end

end