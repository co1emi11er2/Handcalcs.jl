"""
Module for better calc documentation.
"""
module Handcalcs

using Latexify: latexify
using MacroTools: postwalk
using MacroTools
using LaTeXStrings
using CodeTracking, Revise
using InteractiveUtils

export @handcalc, @handcalcs, latexify, multiline_latex, calc_Ix, calc_Iy, calc_I, @handfunc, @handtest, parse_func_args, _merge_args!

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
    expr_post = expr.head == :(=) ? expr.args[2:end] : expr
    expr_numeric = _walk_expr(expr_post, math_syms)
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

function _walk_expr(expr::Vector, math_syms)
    postwalk(x -> (x isa Symbol) & (x ∉ math_syms) ? numeric_sub(x) : x, expr...)
end

function _walk_expr(expr::Expr, math_syms)
    postwalk(x -> (x isa Symbol) & (x ∉ math_syms) ? numeric_sub(x) : x, expr)
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
    println(typeof(expr))
    # If singular expression
    if expr.head == :(=)
        push!(exprs, :(@handcalc $(expr) $(kwargs...)))
        return Expr(:block, esc(Expr(:call, :multiline_latex, exprs...)))
    end
    # If multiple Expressions
    for arg in expr.args
        if typeof(arg) == String # type string will be converted to a comment
            comment = latexstring("\\text{  }(\\text{", arg, "})")
            push!(exprs, comment)
		elseif typeof(arg) == Expr # type expression will be latexified
            push!(exprs, :(@handcalc $(arg) $(kwargs...)))
		else
			error("Code pieces should be of type string or expression")
        end
    end
    return Expr(:block, esc(Expr(:call, :multiline_latex, exprs...)))
end

function multiline_latex(exprs...)
    multi_latex = L"\begin{align}"[1:end-1] # remove the $ from end of string
    for (i, expr) in enumerate(exprs)
        if occursin("text{  }", expr)
            multi_latex *= expr[2:end-1] # remove the $ from end and beginning of string
        else
            multi_latex *=  "\n" * (i ==1 ? "" : "\\\\") * replace(expr[2:end-1], "="=>"&=", count=1) # remove the $ from end and beginning of string
        end
    end
    multi_latex *= "\n" * L"\end{align}"[2:end] # remove the $ from beginning of string
    return latexstring(multi_latex)
end

function calc_Ix(b, h) 
    Ix = b*h^3/12
	return Ix;
end

function calc_Iy(h, b=15; expo=3, denominator=12)
    Iy = h*b^expo/denominator
    return Iy
end

function calc_I()
    I = 5*15^3/12
    return I
end


# TODO: Write macro that will parse a function
macro handfunc(expr, kwargs...)
    expr = unblock(expr)
	expr = rmlines(expr)
    func_head = expr.args[2].args[1]
    func_args = expr.args[2].args
    found_func = InteractiveUtils.gen_call_with_extracted_types_and_kwargs(__module__, :code_expr, (expr.args[2],))
    found_func_args = found_func.args[1]
    found_kw_dict, found_pos_arr = parse_func_args(found_func_args)
    kw_dict, pos_arr = parse_func_args(func_args)
    kw_dict, pos_arr = _clean_args(kw_dict, pos_arr)
    _merge_args!(found_kw_dict, found_pos_arr, kw_dict, pos_arr)
    return quote
        $found_func
    end
    # exprs = []
    # println(expr)
    # @show($(expr.args[2]))
end

macro handtest(ex)
    InteractiveUtils.gen_call_with_extracted_types_and_kwargs(__module__, :code_expr, (ex,))
end



function parse_func_args(func_args)
    pos_arr = []
    len_args = length(func_args.args)
    if len_args == 1 # check if any function arguments
        return nothing, nothing
    end

    # parse keyword function arguments
    iskw, kw_dict = _extract_kw_args(func_args.args[2])

    # parse positional function arguments
    idx = iskw ? 3 : 2 # default assumes there are keywords
    if len_args == idx-1 # check if any positional arguments
        return kw_dict, nothing
    end
    for arg in func_args.args[idx:end] # this skips the function name and keywords
        arr = _extract_arg(arg)
        append!(pos_arr, arr)
    end
    return kw_dict, pos_arr
end

function _extract_kw_args(arg::Expr)
    iskw = true
    dict = Dict()
    if arg.head == :parameters # check if function keyword arguments
        for kw in arg.args
            dict = _extract_kw(kw, dict)
        end
        return iskw, dict
    else
        error("Not a keyword argument.")
    end
end

function _extract_kw_args(arg::Symbol)
    iskw = false
    dict = nothing
    return iskw, dict
end

function _extract_kw(kw::Expr, dict::Dict)
    dict[kw.args[1]] =  kw.args[2]
    return dict
end

function _extract_kw(arg::Symbol, dict::Dict)
    dict[kw] =  nothing
    return dict
end

function _extract_arg(arg::Expr) 
    arr = []
    if arg.head == :kw # check if default function arguments (not kw (keyword))
        append!(arr, [[arg.args[1] arg.args[2]]])
        return arr
    else
        error("Not a default argument.")
    end
end

function _extract_arg(arg::Symbol) 
    arr = [[arg nothing]]
    return arr
end

function _clean_args(kw_dict, pos_arr)
    kw_dict = isnothing(kw_dict) ? Dict() : kw_dict
    arr_acc = []
    for (i, arr) in enumerate(pos_arr)
        if !isnothing(arr[2])
            kw_dict[arr[1]] = arr[2]
        else
            append!(arr_acc, [arr])
        end
    end
    return kw_dict, arr_acc
end

function _merge_args!(found_kw_dict::Dict, found_pos_arr, kw_dict::Dict, pos_arr)
    # overwrite keywords
    if !isnothing(found_kw_dict)
        for kw in keys(kw_dict)
            found_kw_dict[kw] = kw_dict[kw]
        end
    end

    # merge positional arguments
    if !isnothing(found_pos_arr)
        for (i, arr) in enumerate(pos_arr)
            found_pos_arr[i][2] = arr[1]
        end
    end
    
end

function _dict_to_expr(dict::Dict)
    # check if the argument is a dictionary

    # create an empty expression
    expr = Expr(:block)
    # loop through the key-value pairs in the dictionary
    for (key, value) in dict
        # check if the key is a symbol
        if typeof(key) == Symbol
            # append the assignment to the expression
                        push!(expr.args, Expr(:(=), key, value))
        else
            # throw an error if the key is not a symbol
            error("Invalid key: $(key)")
        end
    end
    # return the expression
    return expr
end

end
