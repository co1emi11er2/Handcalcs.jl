```@meta
CurrentModule = Handcalcs
```

# Handcalcs

## Introduction

This is the documentation for [Handcalcs.jl](https://github.com/co1emi11er2/Handcalcs.jl). This package supplies macros to generate ``\LaTeX`` formatted strings from mathmatical formulas. This package takes inspiration from [handcalcs.py](https://github.com/connorferster/handcalcs) which is a python package that works best in jupyter notebooks. The goal is to get the functionalities of that package and bring them to Julia. At this point, I believe most (if not all) of the features from the python package are here. This package is an extension of [Latexify.jl](https://github.com/korsbo/Latexify.jl). The `@latexdefine` macro is similar to the main `@handcalcs` macro, but instead of only a symbolic rendering it also renders the numeric substitution.

The package can be used with [Unitful.jl](https://painterqubits.github.io/Unitful.jl/stable/) and can also be used with [Quarto](https://quarto.org/) to produce high quality calculations. See the [Flexural Design Example](https://github.com/co1emi11er2/Handcalcs.jl/blob/master/examples/Flexure%20Design/FlexureDesign.pdf) for an example.


## Installation
This package is registered in the Julia registry, so to install it you can just
run:

```julia
Pkg.add("Handcalcs")
```

## Basic example:

### Single line expression

```@example main
using Handcalcs
a = 3
b = 4
@handcalcs c = sqrt(a^2 + b^2)
```


## Future Plans

There are a number of things that I would like to implement to the package. Here is a list of features I hope to add:

- Maybe a symbolic mode that would essentially be like @latexdefine but you get function unrolling and multiline support.
- I have also thought about adding a setting that you could change if you were within the REPL and instead of latex (since it is not very readable) to instead output a simple string instead. For example: `I_x = b*h^3/12 = 5*15^3/12 = 1406.25`.
