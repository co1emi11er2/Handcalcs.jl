# Handcalcs

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://co1emi11er2.github.io/Handcalcs.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://co1emi11er2.github.io/Handcalcs.jl/dev/)
[![Build Status](https://github.com/co1emi11er2/Handcalcs.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/co1emi11er2/Handcalcs.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/co1emi11er2/Handcalcs.jl?svg=true)](https://ci.appveyor.com/project/co1emi11er2/Handcalcs-jl)
[![Coverage](https://codecov.io/gh/co1emi11er2/Handcalcs.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/co1emi11er2/Handcalcs.jl)
[![Coverage Status](https://coveralls.io/repos/github/co1emi11er2/Handcalcs.jl/badge.svg?branch=master)](https://coveralls.io/github/co1emi11er2/Handcalcs.jl?branch=master)

## Introduction

This is a package for generating LaTeX maths and designed to improve documentation for your calculations. This package was designed to work in both jupyter and pluto.

This package supplies macros to generate ``\LaTeX`` formatted strings from mathmatical formulas. This package takes inspiration from [handcalcs.py](https://github.com/connorferster/handcalcs) which is a python package that works best in jupyter notebooks. The goal is to get the functionalities of that package and bring them to Julia. The current version of Handcalcs.jl is working for typical algebraic formulas. Future plans are to integrate the package with [Unitful.jl](https://painterqubits.github.io/Unitful.jl/stable/), be able to render the algebraic expressions within a function, and many other things. This package is an extension of [Latexify.jl](https://github.com/korsbo/Latexify.jl). The `@latexdefine` macro is similar to the main `@handcalc` macro, but instead of only a symbolic rendering it also renders the numeric substitution.

## Basic Demo
*Will add gif soon!*

## Basic example:
### @handcalc macro
```julia
using Handcalcs
a = 3
b = 4
@handcalc c = sqrt(a^2 + b^2)
```

This generates a LaTeXString (from
[LaTeXStrings.jl](https://github.com/stevengj/LaTeXStrings.jl)) which, when
printed looks like:
```LaTeX
$c = \sqrt{a^{2} + b^{2}} = \sqrt{3^{2} + 4^{2}} = 5.0$
```

And when this LaTeXString is displayed in an environment which supports the
tex/latex MIME type (Jupyter and Pluto notebooks, Jupyterlab and Hydrogen for
Atom) it will automatically render as:

![fraction](/assets/handcalc_latex_render.png)

### @handcalcs macro

This macro is the same as @handcalc but for multiple expressions. You can add comments to the side of the expression by adding a string beside the expression. Note: the variables being assigned in the expressions are evaluated (see [docs]() for more details). See example below.

```julia
a = 2
b = 5
@handcalcs begin 
    c = a + b; "eq 1";
    d = a - c
end
```

```LaTeX
$\begin{align}
c &= a + b = 2 + 5 = 7\text{  }(\text{eq 1})
\\d &= a - c = 2 - 7 = -5
\end{align}$"
```
![fraction](/assets/handcalcs_latex_render.png)


## Installation
This package is registered in the Julia registry, so to install it you can just
run:

```julia
Pkg.add("Handcalcs")
```

## Further information
For further information see the [docs]() *- Note: docs link not working. Will fix soon!*
