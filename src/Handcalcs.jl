"""
Module for better calc documentation.
"""
module Handcalcs

using Latexify: latexify, set_default, get_default, reset_default, @latexdefine
using MacroTools: postwalk, prewalk
using MacroTools
using LaTeXStrings
using CodeTracking, Revise
using InteractiveUtils
import AbstractTrees: Leaves

export @handcalc, @handcalcs, @handfunc, multiline_latex, collect_exprs
export set_handcalcs, reset_handcalcs, get_handcalcs #, initialize_format
export latexify, @latexdefine, set_default, get_default, reset_default

# function initialize_format()
#     @eval begin
#         using Format
#         set_default(fmt=x->format(round(x, digits=4)))
#     end
# end
const math_syms = [
    :*, :/, :^, :+, :-, :%,
    :.*, :./, :.^, :.+, :.-, :.%,
    :<, :>, Symbol(==), :<=, :>=,
    :.<, :.>, :.==, :.<=, :.>=,
    :sqrt, :sin, :cos, :tan]
const h_syms = [:cols, :spa, :h_env]

include("default_h_kwargs.jl")
include("handcalc_marco.jl")
include("handcalcs_macro.jl")
include("handfunc_macro.jl")

end
