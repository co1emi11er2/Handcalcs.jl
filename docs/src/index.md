```@meta
CurrentModule = Handcalcs
```

# Handcalcs

## Introduction

This is the documentation for [Handcalcs.jl](https://github.com/co1emi11er2/Handcalcs.jl). This package supplies macros to generate ``\LaTeX`` formatted strings from mathmatical formulas. This package takes inspiration from [handcalcs.py](https://github.com/connorferster/handcalcs) which is a python package that works best in jupyter notebooks. The goal is to get the functionalities of that package and bring them to Julia. The current version of Handcalcs.jl is working for typical algebraic formulas. Future plans are to integrate the package with [Unitful.jl](https://painterqubits.github.io/Unitful.jl/stable/), be able to render the algebraic expressions within a function, and many other things. This package is an extension of [Latexify.jl](https://github.com/korsbo/Latexify.jl). The `@latexdefine` macro is similar to the main `@handcalcs` macro, but instead of only a symbolic rendering it also renders the numeric substitution.

## Examples
A simple example for a single expression:

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

A simple example for multiple expressions:
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

A simple example for a function:
```@example main
@handfunc Ix = calc_Ix(5, 15)
```
The `Ix` variable is evaluated. Ix being the variable assigned in the @handfunc part (variables within function are not defined in the global name space). If you assign it to a different variable then that will be the variable defined (although you will still see it as Ix in the latex portion). Also note that return statements are filtered out of the function body, so keep relevant parts separate from return statements.

Current Limitations for `@handfunc`
- You must pass numbers or symbols (not fields of objects). This is also a current limitation of the @handcalcs macro.
- I believe the function needs to be defined in another package. The @code_expr macro from CodeTracking.jl does not see functions in Main for some reason.
- It curently can only be used in the global scope. You can not use it within a function unless you use numbers within the function you want to call.

## Using Unitful with UnitfulLatexify

The package has plans to work with the packages [Unitful.jl](https://painterqubits.github.io/Unitful.jl/stable/) and [UnitfulLatexify.jl](https://gustaphe.github.io/UnitfulLatexify.jl/stable/). The only issue known is the rendering of units under exponents. Parenthesis need to wrap the numerical value and the unit for it to display correctly. See example below.

```@example main
using Unitful, UnitfulLatexify
a = 2u"inch"
b = -5u"inch"
@handcalc c = sqrt(a^2 + b^2)
```
You can see that it looks as though only the unit is being squared. This should be an easy fix. However, not sure if this should be done in this package or the UnitfulLatexify package.

## Future Plans

There are a number of things that I would like to implement to the package. See [handcalcs.py](https://github.com/connorferster/handcalcs) for potential features. Here is a list of features I hope to add:

- A parameters macro similar to python package
- A way to break down a ``\LaTeX`` equation that is too long to multiple lines

## References
```@index
```

```@autodocs
Modules = [Handcalcs]
```
