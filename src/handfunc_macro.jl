"""
    @handfunc expression

Create `LaTeXString` representing `expressions`. These expressions represent a number of
expressions that exist within the function that was called.
A single expression being a variable followed by an equals sign and the function being called.
The expression is evaluated as well (not the expressions within the function).
The RHS can be formatted or otherwise transformed by supplying a function as kwarg `post`.

# Examples
```julia-repl
julia> @handfunc Iy = calc_Ix(5, 15)
L"\$\\begin{aligned}
Ix &= \\frac{b \\cdot h^{3}}{12} = \\frac{5 \\cdot 15^{3}}{12} = 1406.25
\\end{aligned}\$"

julia> Iy
1406.25

```
Note how Iy is evaluated but Ix is not.
"""
macro handfunc(expr, kwargs...)
    expr = unblock(expr)
	expr = rmlines(expr)
    var = esc(expr.args[1])
    eq = esc(expr.args[2])
    return quote
        found_module = $(esc(:(@which $(expr.args[2])))).module
        found_func = $(esc(:(Handcalcs.@code_expr $(expr.args[2]))))
        func_args = $(esc(:(Handcalcs.@func_vars $(expr.args[2]))))
        latex_eq = handfunc(found_func, func_args, $kwargs)
        latex = @eval #=found_module=# $(Expr(:$, :latex_eq))
        $var = $eq
        latex
    end
end

macro func_vars(expr)
    expr_post = expr.head == :(=) ? expr.args[2:end] : expr
    expr_numeric = _walk_expr(expr_post, math_syms)
    return esc(Meta.quot(expr_numeric))
end

function handfunc(found_func, func_args, kwargs)
    func_body = remove_return_statements(found_func.args[2])
    func_body = unblock(func_body)
    func_body = rmlines(func_body)
    # TODO: Can I step through function body and add module in front of function calls?
    @show func_body
    @show typeof(func_body)
    dump(func_body)
    kw_dict, pos_arr = _initialize_kw_and_pos_args(found_func, func_args)
    return_expr = _initialize_expr(kw_dict, pos_arr)
    push!(return_expr.args[2].args, :(@handcalcs $(func_body) $(kwargs...)))
    # ret = @eval eval_module $return_expr
    return return_expr
end

function _walk_func_body(expr::Expr)
    nothing
end

function _initialize_kw_and_pos_args(found_func, func_args)
    found_func_args = found_func.args[1]
    found_kw_dict, found_pos_arr = parse_func_args(found_func_args, _extract_kw_args, _extract_arg)
    kw_dict, pos_arr = parse_func_args(func_args, _extract_kw_args, _extract_arg)
    kw_dict, pos_arr = _clean_args(kw_dict, pos_arr)

    _merge_args!(found_kw_dict, found_pos_arr, kw_dict, pos_arr)
    return found_kw_dict, found_pos_arr
end

function parse_func_args(func_args, kw_func, pos_func)
    pos_arr = []

    # ignore :where call 
    func_args = func_args.head == :where ? func_args.args[1] : func_args

    len_args = length(func_args.args)
    if len_args == 1 # check if any function arguments
        return nothing, nothing
    end
    
    # parse keyword function arguments
    iskw, kw_dict = kw_func(func_args.args[2])

    # parse positional function arguments
    idx = iskw ? 3 : 2 # default assumes there are keywords
    if len_args == idx-1 # check if any positional arguments
        return kw_dict, nothing
    end
    for arg in func_args.args[idx:end] # this skips the function name and keyword
        arr = pos_func(arg)
        append!(pos_arr, arr)
    end
    return kw_dict, pos_arr
end

function _extract_kw_args(arg::Expr)
    if arg.head == :parameters # check if function keyword arguments
        iskw = true
        dict = Dict()
        for kw in arg.args
            dict = _extract_kw(kw, dict)
        end
        return iskw, dict
    else
        iskw = false
        dict = nothing
        return iskw, dict
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

function _extract_kw(kw::Symbol, dict::Dict)
    dict[kw] =  nothing
    return dict
end

function _extract_arg(arg::Expr) 
    arr = []
    if arg.head == :kw # check if default function arguments (not kw (keyword))
        append!(arr, [Any[arg.args[1] arg.args[2]]])
        return arr
    elseif arg.head == :(.)
        append!(arr, [Any[arg nothing]])
        return arr
    elseif arg.head == :(::)
        append!(arr, [Any[arg.args[1] nothing]])
    else
        append!(arr, [Any[arg nothing]])
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
    left_tuple_expr = expr.args[1].args[1].args
    right_tuple_expr = expr.args[1].args[2].args
    # loop through the key-value pairs in the dictionary
    for (key, value) in dict
        # check if the key is a symbol
        if typeof(key) == Symbol
            # append the assignment to the expression
            push!(left_tuple_expr, key)
            push!(right_tuple_expr, value)
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
    left_tuple_expr = expr.args[1].args[1].args
    right_tuple_expr = expr.args[1].args[2].args
    for (arg_name, arg_val) in arr
        push!(left_tuple_expr, arg_name)
        arg_val = typeof(arg_val) == Symbol ? QuoteNode(arg_val) : arg_val
        push!(right_tuple_expr, arg_val)
    end
end

function _arr_to_expr!(expr::Expr, arr)
    #do nothing
end

function _initialize_expr(kw_dict, pos_arr)
    expr = Expr(:let, Expr(:(=),Expr(:tuple,), Expr(:tuple,)), Expr(:block,))
    if !isnothing(kw_dict)
    _dict_to_expr!(expr, kw_dict)
    end
    if !isnothing(pos_arr)
    _arr_to_expr!(expr, pos_arr)
    end
    return expr
end

function remove_return_statements(expr::Expr)
    # Initialize an empty expression
    filtered_expr = Expr(:block)

    # Iterate through the subexpressions
    for subexpr in expr.args
        if !(subexpr isa Expr && subexpr.head == :return)
            # If it's not a return statement, add it to the filtered expression
            push!(filtered_expr.args, subexpr)
        end
    end

    return filtered_expr
end