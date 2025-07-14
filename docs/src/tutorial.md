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
- `precision`: formats numbers to a max precision. Given `precision = 2`, `2.567` will show as `2.57`, while `2.5` would show as `2.5`
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
end not_funcs = [:sin :cos]
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
    :log10, :√]
```

If you want to add functions to your specific project, you can do the following:

```@example main
set_handcalcs(not_funcs = [:foo :bar :baz])
```

Current Limitations for `@handcalcs`

- I believe the function needs to be defined in another package. The @code_expr macro from CodeTracking.jl does not see functions in Main for some reason.

## Options for if statements

If statements have two different formats in how they can be displayed. The default format is different than how Latexify would display the if statement. The reasoning was to show an if statement more like the way you would if you were performing a calculation by hand and to also integrate function unrolling. The default format (`parse_ifs=true`), only shows the branches of the if statement that pass the logic statements within the if statement. This is nice, because you only see the equations that are relevant to that specific problem. See the example below:

```@example main
@handcalcs begin
x = 10
if x > 5
    Ix = calc_Ix(5, 15)
else
    Ix = calc_Ix(10, 15)
end
end
```

Nested if statements work as well. See below:

```@example main
@handcalcs begin
x = 10
y = 5
if x > 5
    if y < 3
        Ix = calc_Ix(5, 15)
    else
        Ix = calc_Ix(3, 15)
    end
else
    Ix = calc_Ix(10, 15)
end
end
```

The other format (`parse_ifs=false`) looks more like the Latexify format. However, nested ifs don't always work and function unrolling does not work. 

```@example main
@handcalcs begin
x = 10
y = 5
if x > 5
    Ix = calc_Ix(5, 15)
else
    Ix = calc_Ix(10, 15)
end
end parse_ifs=false
```

You can also write the if statement like so:

```@example main
@handcalcs begin
x = 10
y = 5
Ix = if x > 5
    calc_Ix(5, 15)
else
    calc_Ix(10, 15)
end
end
```

This way does not require you to write the `parse_ifs=false`, although that may change in future versions. If you prefer the Latexify method you can change the default settings. See next section for more info.

## Changing Default Settings

You can change the default settings using the `set_handcalcs` function *(similar to the `set_default` function in Latexify)*.

### Settings

- `cols` - change the number of columns the expression returns (default = 1).
- `spa` - change the vertical line spacing between expressions (default = 10).
- `len`: can set to `:long` and it will split equation to multiple lines
- `color`: change the color of the output (`:blue`, `:red`, etc)
- `h_env`: choose between "aligned" (default), "align" and other LaTeX options
- `h_render`: choose between "equation", symbolic", "numeric" and "both" (default)
- `precision`: formats numbers to a max precision. Given `precision = 2`, `2.567` will show as `2.57`, while `2.5` would show as `2.5`
- `not_funcs`: name the functions you do not want to "unroll" 
- `parse_pipe`: a boolean value (default=true) to remove pipe from equation. This is intended for unitful equations.
- `parse_ifs`: a boolean value (default=true) to unroll if statements. Function unrolling works and it only shows the parts of the if statement that were met.
- `disable`: disable handcalcs rendering to run simulations and turn it back on when needed.

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

### Set default precision

Handcalcs provides a setting to include a default precision. This setting formats a number to a max precision. See example below:

```@example main
@handcalcs begin
    a = 2.567
    b = 2.5
    c = 1
    d = true
end precision = 2
```

This setting is off by default, but you can add a default with the `set_handcalcs` function.

```julia
set_handcalcs(precision=4)
```

If other formats are preferred, then use the `fmt` option provided by Latexify. 

```@example main
@handcalcs begin
    a = 2.567
    b = 2.5
    c = 1
    d = true
end fmt = "%.2f"
```

The `set_default` function is re-exported from the Latexify.jl package. See [here](https://korsbo.github.io/Latexify.jl/stable/#Setting-your-own-defaults) for more Latexify default settings.

### Set Rendering Format

Handcalcs provides a setting to include a different rendering format. The choices are between `equation`, `symbolic`, `numeric`, or `both` (default).

See example below for an equation rendering:

```@example main
set_handcalcs(h_render=:equation)
b = 5 # width
h = 15 # height
@handcalcs Ix = calc_Ix(b, h) # function is defined in TestHandcalcFunctions package
```

Note: `I_x` is evaluated.

```@example main
@handcalcs I_x
```

See example below for a symbolic rendering:

```@example main
set_handcalcs(h_render=:symbolic)
b = 5 # width
h = 15 # height
@handcalcs Ix = calc_Ix(b, h) # function is defined in TestHandcalcFunctions package
```

See example below for a numeric rendering:

```@example main
set_handcalcs(h_render=:numeric)
b = 5 # width
h = 15 # height
@handcalcs Ix = calc_Ix(b, h) # function is defined in TestHandcalcFunctions package
```

This is really meant to be a setting overall, but you can use the `set_handcalcs` function to turn the setting on, then use it again afterward to turn it back to the default.

```@example main
set_handcalcs(h_render=:both) # set handcalcs back to default
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

## Pluto

Handcalcs renders in [Pluto.jl](https://plutojl.org/). There is one function specifically for rendering in pluto.

```@docs
left_align_in_pluto
```

!!! note "Use `begin` and `end`"
    Pluto outputs an extra variable description when using `@handcalcs` without `begin` and `end`.
    
    As an example:

    ```julia
    @handcalcs x = 2
    ```

    Instead of writing the code above, write:

    ```julia
    @handcalcs begin 
        x = 2 
    end
    ```

