```@meta
CurrentModule = Handcalcs
```

# Handcalcs

This is the documentation for [Handcalcs.jl](https://github.com/co1emi11er2/Handcalcs.jl). This package supplies macros to generate ``\LaTeX`` formatted strings from mathmatical formulas. This package takes inspiration from [handcalcs.py](https://github.com/connorferster/handcalcs) which is a python package that works best in jupyter notebooks. The goal is to get the functionalities of that package and bring them to Julia. The current version of Handcalcs.jl is working for typical algebraic formulas. Future plans are to integrate the package with [Unitful.jl](https://painterqubits.github.io/Unitful.jl/stable/), be able to render the algebraic expressions within a function, and many other things. This package is an extension of [Latexify.jl](https://github.com/korsbo/Latexify.jl). The `@latexdefine` macro is similar to the main `@handcalc` macro, but instead of only a symbolic rendering it also renders the numeric substitution.

A simple example:

```@example main
using Handcalcs
a = 2
b = -5
c = 2
@handcalc x = -b + sqrt(b^2 - 2*a*c)/ (2*a)
```

```@index
```

```@autodocs
Modules = [Handcalcs]
```
