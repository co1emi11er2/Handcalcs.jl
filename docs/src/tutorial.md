# Tutorial

Below are a series of examples of the capabilities of the Handcalcs package.

## Expression Examples

### A single expression example:

```@example main
using Handcalcs
a = 2
b = -5
c = 2
@handcalcs x = (-b + sqrt(b^2 - 4*a*c))/ (2*a)
```

The variable x is still evaluated:

```@example main
x
```

### An example of multiple expressions:

Note: If you input strings instead of expressions into handcalcs, they will be enclosed in parenthesis and added to the end of the last expression line.

```@example main
b = 5 # width
h = 15 # height
@handcalcs begin
  I_x = (b*h^3)/12; "moment of inertia about x";
  I_y = (h*b^3)/12; "moment of inertia about y";
end
```

The `I_x` and `I_y` variables are still evaluated:

```@example main
println("The moment of inertia about the x direction is: $I_x\n
The moment of inertia about the y direction is: $I_y\n")
```

## Changing the Output Settings

 You can edit the layout of the returned LaTeX expression with the following kwargs:

- `cols` - change the number of columns the expression returns (default = 1).
- `spa` - change the vertical line spacing between expressions (default = 10).
- `color`: change the color of the output (`:blue`, `:red`, etc)
- `h_env` - change the environment (default = "aligned").
- `len` - change expression to write to multiple lines using `len=:long` (default = :short).

**Note: `@handcalcs` macro can also take symbols of defined variables. See below.**

```@example main
a, b, c = 1, 2, 3
@handcalcs begin
    a # see note above
    b
    c
    x = 4
    y = 5
    z = 6
end cols=3 spa=0 color=:blue
```
A list of additional colors can be found [here](https://www.overleaf.com/learn/latex/Using_colors_in_LaTeX). Not all of the colors in the link work, but a good number of them do.

Below is an example of what you can do if an expression is really long.

```@example main
a, b, c = 2, -5, 2
@handcalcs begin
    x1 = (-b + sqrt(b^2 - 4*a*c))/(2*a)
    x2 = (-b - sqrt(b^2 - 4*a*c))/(2*a)
end len = :long # using len argument forces cols=1
```

## Function Examples

The `@handcalcs` macro will now automatically try to "unroll" the expressions within a function when the expression has the following pattern: `variable = function_name(args...; kwargs...)`. Note that this is recursive, so if you have a function that calls other functions where the expressions that call the function are of the format mentioned, it will continue to step into each function to "unroll" all expressions.

One issue that can arise are for the functions that you do not want to unroll. Consider the expression: `y = sin(x)` or ` y = x + 5`. Both of these expressions match the format: `variable = function_name(args...; kwargs...)` and would be unrolled. This would result in an error since these functions don't have generic math expressions that can be latexified defining the function. You will need to use the `not_funcs` keyword to manually tell the @handcalcs macro to pass over these functions. Some of the common math functions that you will not want to unroll are automatically passed over. See examples below.

### An example for rendering expressions within a function:

```@example other
function calc_Ix(b, h) # function defined in TestHandcalcFunctions
    Ix = b*h^3/12
    return Ix
end;
```

```@example main
using TestHandcalcFunctions
b = 5 # width
h = 15 # height
@handcalcs Ix = calc_Ix(b, h) # function is defined in TestHandcalcFunctions package
```

The `Ix` variable is evaluated. Ix being the variable assigned in the @handcalcs part (variables within function are not defined in the global name space). If you assign it to a different variable then that will be the variable defined (although you will still see it as Ix in the latex portion). Also note that return statements are filtered out of the function body, so keep relevant parts separate from return statements.

```@example other
function calc_Is(b, h) # function defined in TestHandcalcFunctions
    Ix = calc_Ix(b, h)
    Iy = calc_Iy(h, b)
    return Ix, Iy
end;
```

```@example main
using TestHandcalcFunctions
x = 0
@handcalcs begin
y = sin(x)
z = cos(x)
I_x, I_y = TestHandcalcFunctions.calc_Is(5, 15)
end not_funcs = [sin cos]
```

In the above example `sin` and `cos` were passed over and `calc_Is` was not. As you can see, the `calc_Is` function was a function that called other functions, and the `@handcalcs` macro continued to step into each function to unroll all expressions. Please see below for a list of the current functions that are passed over automatically. Please submit a pull request if you would like to add more generic math functions that I have left out. 

```julia
const math_syms = [
    :*, :/, :^, :+, :-, :%,
    :.*, :./, :.^, :.+, :.-, :.%,
    :<, :>, Symbol(==), :<=, :>=,
    :.<, :.>, :.==, :.<=, :.>=,
    :sqrt, :sin, :cos, :tan, :sum, 
    :cumsum, :max, :min, :exp, :log,
    :log10]
```

If you want to add functions to your specific project, you can do the following:

```@example main
set_handcalcs(not_funcs = [:foo :bar :baz])
```

Current Limitations for `@handcalcs`

- I believe the function needs to be defined in another package. The @code_expr macro from CodeTracking.jl does not see functions in Main for some reason.
- If the function has other function calls within it's body that are not available in Main, then the macro will error.

## Changing Default Settings:

You can change the default settings using the `set_handcalcs` function *(similar to the `set_default` function in Latexify)*.

### Settings

- `cols` - change the number of columns the expression returns (default = 1).
- `spa` - change the vertical line spacing between expressions (default = 10).
- `len`: can set to `:long` and it will split equation to multiple lines
- `color`: change the color of the output (`:blue`, `:red`, etc)
- `h_env`: choose between "aligned" (default), "align" and other LaTeX options
- `not_funcs`: name the functions you do not want to "unroll" 
- `parse_pipe`: a boolean value (default=true) to remove pipe from equation. This is intended for unitful equations.
- disable: disable handcalcs rendering to run simulations and turn it back on when needed.

```julia
set_handcalcs(cols=3)
```

Note that this changes Handcalcs.jl from within and should therefore only be used in your own Julia sessions (do not call this from within your packages).

The calls are additive so that a new call with

```julia
set_handcalcs(spa = 5)
```

will not cancel out the changes we just made to `cols`. 

To view your changes, use

```julia
get_handcalcs()
```

and to reset your changes, use

```julia
reset_handcalcs()
```

## Using Unitful with UnitfulLatexify

The package integrates with the packages [Unitful.jl](https://painterqubits.github.io/Unitful.jl/stable/) and [UnitfulLatexify.jl](https://gustaphe.github.io/UnitfulLatexify.jl/stable/). 

```@example main
using Unitful, UnitfulLatexify
a = 2u"inch"
b = -5u"inch"
@handcalcs c = sqrt(a^2 + b^2)
```

If you want to set the units of the output, you can write it the same way you would using Unitful. The `@handcalcs` macro will parse the `|>` operator out of the output while still evaluating the result with the conversion.

```@example main
b = 40u"ft"
t = 8.5u"inch"
@handcalcs begin
    b
    t
    a = b * t       |> u"inch"^2
    Ix = b*t^3/12   |> u"inch"^4
end
```