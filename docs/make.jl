using Handcalcs, TestHandcalcFunctions
using Documenter

DocMeta.setdocmeta!(Handcalcs, :DocTestSetup, :(using Handcalcs); recursive=true)

makedocs(;
    modules=[Handcalcs],
    authors="Cole Miller",
    repo="https://github.com/co1emi11er2/Handcalcs.jl/blob/{commit}{path}#{line}",
    sitename="Handcalcs.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://co1emi11er2.github.io/Handcalcs.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/co1emi11er2/Handcalcs.jl",
    devbranch="master",
)
