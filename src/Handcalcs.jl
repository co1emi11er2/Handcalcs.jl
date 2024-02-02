module Handcalcs

# Write your package code here.
using Latexify: latexify
using MacroTools: postwalk
using MacroTools
using LaTeXStrings
# using CodeTracking, Revise

export @handcalc, @handcalcs, latexify, multiline_latex, calc_Ix, @handfunc

function hello()
    println("hello world")
end

macro handcalc(expr, kwargs...)
    expr = unblock(expr)
	expr = rmlines(expr)
    math_syms = [:*, :/, :^, :+, :-, :%]
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
            multi_latex *=  "\\\\" * expr[2:end-1] # remove the $ from end and beginning of string
        end
    end
    multi_latex *= L"\end{align}"[2:end] # remove the $ from beginning of string
    return latexstring(multi_latex)
end

function calc_Ix(b, h) 
	return b*h^3/12;
end

# Write macro that will parse a function
macro handfunc(expr, kwargs...)
    expr = unblock(expr)
	expr = rmlines(expr)
    exprs = []
    println(expr)
    # @show($(expr.args[2]))
end

end