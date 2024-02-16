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

export @handcalc, @handcalcs, latexify, multiline_latex, calc_Ix, calc_Iy, calc_I, @handfunc, @handtest, parse_func_args, _merge_args!, handfunc

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
    d = if b > 4
        b * 5
    else
        b + 5
    end
    c = h + 6
    Ix = b*h^3/12
    
end

function calc_Iy(h, b=15; expo=3, denominator=12)
    Iy = h*b^expo/denominator
    return Iy
end

function calc_I()
    I = 5*15^3/12
    # return I
end

function area_sqare(side)
    area = side^2
end

function area_rectangle(l, w)
    area = l * w
end


# TODO: Write macro that will parse a function
macro handfunc(expr, kwargs...)
    e = esc(expr.args[1])
    r = esc(expr.args[2])
    expr = unblock(expr)
	expr = rmlines(expr)
    func_head = expr.args[2].args[1]
    func_args = QuoteNode(expr.args[2])
    found_func = InteractiveUtils.gen_call_with_extracted_types_and_kwargs(__module__, :code_expr, (expr.args[2],))
    # println(found_func)
    return quote
        x = handfunc($found_func, $func_args)
        latex = Main.eval(x)
        $e = $r
        latex
        # display(x)
        # $exprs
    end
    # exprs = []
    # println(expr)
    # @show($(expr.args[2]))
end

macro handtest(ex)
    InteractiveUtils.gen_call_with_extracted_types_and_kwargs(__module__, :code_expr, (ex,))
end

function handfunc(found_func, func_args)
    func_body = unblock(found_func.args[2])
    func_body = rmlines(func_body)
    kw_dict, pos_arr = _initialize_kw_and_pos_args(found_func, func_args)
    return_expr = _initialize_expr(kw_dict, pos_arr)
    push!(return_expr.args[2].args, :(@handcalcs $func_body))
    return return_expr
end

function _initialize_kw_and_pos_args(found_func, func_args)
    found_func_args = found_func.args[1]
    # println(found_func)
    # println(found_func_args)
    # println(func_args)
    found_kw_dict, found_pos_arr = parse_func_args(found_func_args)
    kw_dict, pos_arr = parse_func_args(func_args)
    kw_dict, pos_arr = _clean_args(kw_dict, pos_arr)

    _merge_args!(found_kw_dict, found_pos_arr, kw_dict, pos_arr)
    # println(found_kw_dict)
    # println(found_pos_arr)
    return found_kw_dict, found_pos_arr
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
    for arg in func_args.args[idx:end] # this skips the function name and keyword
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

function _extract_kw_args(arg)
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
    # println(arg)
    # println(arg.head)
    arr = []
    if arg.head == :kw # check if default function arguments (not kw (keyword))
        append!(arr, [Any[arg.args[1] arg.args[2]]])
        return arr
    elseif arg.head == :(.)
        append!(arr, [Any[arg nothing]])
        return arr
    else
        error("Not a default argument.")
    end
end

function _extract_arg(arg) 
    arr = [Any[arg nothing]]
    return arr
end

function _clean_args(kw_dict, pos_arr)
    kw_dict = isnothing(kw_dict) ? Dict() : kw_dict
    arr_acc = []
    if !isnothing(pos_arr)
        for (i, arr) in enumerate(pos_arr)
            if !isnothing(arr[2])
                kw_dict[arr[1]] = arr[2]
            else
                append!(arr_acc, [arr])
            end
        end
    end
    return kw_dict, arr_acc
end

function _merge_args!(found_kw_dict, found_pos_arr, kw_dict, pos_arr)
    # println(found_pos_arr)
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

function _dict_to_expr!(expr::Expr, dict::Dict)
    # loop through the key-value pairs in the dictionary
    for (key, value) in dict
        # check if the key is a symbol
        if typeof(key) == Symbol
            # append the assignment to the expression
            push!(expr.args[2].args, Expr(:(=), key, value))
        else
            # throw an error if the key is not a symbol
            error("Invalid key: $(key)")
        end
    end
end

function _dict_to_expr!(expr::Expr, dict)
    #do nothing
end

function _arr_to_expr!(expr::Expr, arr::Array)
    for (arg_name, arg_val) in arr
        push!(expr.args[2].args, Expr(:(=), arg_name, arg_val))
    end
end

function _arr_to_expr!(expr::Expr, arr)
    #do nothing
end

function _initialize_expr(kw_dict, pos_arr)
    expr = Expr(:let, Expr(:block,), Expr(:block,))
    if !isnothing(kw_dict)
    _dict_to_expr!(expr, kw_dict)
    end
    if !isnothing(pos_arr)
    _arr_to_expr!(expr, pos_arr)
    end
    return expr
end
end
