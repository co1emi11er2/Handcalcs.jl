```@meta
CurrentModule = Handcalcs
```

# Handcalcs

## Introduction

This is the documentation for [Handcalcs.jl](https://github.com/co1emi11er2/Handcalcs.jl). This package supplies macros to generate ``\LaTeX`` formatted strings from mathmatical formulas. This package takes inspiration from [handcalcs.py](https://github.com/connorferster/handcalcs) which is a python package that works best in jupyter notebooks. The goal is to get the functionalities of that package and bring them to Julia. The current version of Handcalcs.jl is working for typical algebraic formulas. Future plans are to integrate the package with [Unitful.jl](https://painterqubits.github.io/Unitful.jl/stable/), be able to render the algebraic expressions within a function, and many other things. This package is an extension of [Latexify.jl](https://github.com/korsbo/Latexify.jl). The `@latexdefine` macro is similar to the main `@handcalc` macro, but instead of only a symbolic rendering it also renders the numeric substitution.

## Examples
A simple example for a single expression:

```@example main
using Handcalcs
a = 2
b = -5
c = 2
@handcalc x = (-b + sqrt(b^2 - 4*a*c))/ (2*a)
```
The variable x is still evaluated:
```@example main
x
```

A simple example for multiple expressions (note the macro is now handcalc**s**):
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
- A macro that will generate ``\LaTeX`` for a function that was called. The generated ``\LaTeX`` would be the algebraic equations within the function
- A way to break down a ``\LaTeX`` equation that is too long to multiple lines

## References
```@index
```

```@autodocs
Modules = [Handcalcs]
```