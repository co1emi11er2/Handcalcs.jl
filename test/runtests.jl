using Handcalcs
using LaTeXStrings, Unitful, UnitfulLatexify
using Test
using TestHandcalcFunctions
using Revise
import IOCapture
isdefined(Main, :Revise) ? Main.Revise.includet("FunctionTestModule.jl") : include("FunctionTestModule.jl")
# using .TestFunctions


@testset "handcalc macro    " begin include("handcalc_macro.jl") end
@testset "Latexify kwargs   " begin include("latexify_kwargs_test.jl") end
@testset "UnitfulLatexify   " begin include("unitful_test.jl") end
@testset "handcalcs macro   " begin include("handcalcs_macro.jl") end
@testset "handfunc macro    " begin include("handfunc_macro.jl") end
@testset "defaults macro    " begin include("default_h_kwargs.jl") end
