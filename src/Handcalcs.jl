"""
Module for better calc documentation.
"""
module Handcalcs

using Latexify: latexify, set_default, get_default, reset_default
using MacroTools: postwalk
using MacroTools
using LaTeXStrings
using CodeTracking, Revise
using InteractiveUtils

export @handcalc, @handcalcs, latexify, multiline_latex, set_default, get_default, reset_default, @handfunc #, initialize_format

# function initialize_format()
#     @eval begin
#         using Format
#         set_default(fmt=x->format(round(x, digits=4)))
#     end
# end

include("handcalc_marco.jl")
include("handcalcs_macro.jl")
include("handfunc_macro.jl")

end
