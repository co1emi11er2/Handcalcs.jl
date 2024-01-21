module Handcalcs

# Write your package code here.
using Latexify: latexify
using MacroTools: postwalk
using MacroTools
using LaTeXStrings

export @handcalc, @handcalcs, latexify, multiline_latex

function hello()
    println("hello world")
end

macro handcalc(expr, kwargs...)
    expr = unblock(expr)
	expr = rmlines(expr)
    expr_numeric = postwalk(x -> x isa Symbol ? numeric_sub(x) : x, expr.args[2:end]...)
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

macro handcalcs(expr, kwargs...)
    expr = unblock(expr)
	expr = rmlines(expr)
    exprs = []
    for arg in expr.args
        if typeof(arg) == String # type string will be converted to a comment
            comment = latexstring("\text{", arg, "}")
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
        # println(expr)
        multi_latex *= expr[2:end-1] * "\\\\" # remove the $ from end and beginning of string
        # multi_latex = latexstring(multi_latex, expr)
    end
    multi_latex *= L"\end{align}"[2:end] # remove the $ from beginning of string
    return latexstring(multi_latex)
end

end