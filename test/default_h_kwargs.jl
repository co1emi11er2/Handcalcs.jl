# using Handcalcs
# using LaTeXStrings, Unitful, UnitfulLatexify
# using Test

# use set_handcalcs
# ***************************************************
# ***************************************************
expected =L"\begin{aligned}
x &= 5
\\[5pt]
y &= 4
\end{aligned}"
set_handcalcs(spa=5)
calc = @handcalcs begin
    x = 5
    y = 4
end
@test calc == expected
@test Dict(:spa => 5) == get_handcalcs()
reset_handcalcs()

expected =LaTeXString("\\begin{align}
x &= 5
\\\\[10pt]
y &= 4
\\end{align}")
set_handcalcs(h_env="align")
calc = @handcalcs begin
    x = 5
    y = 4
end
@test calc == expected
reset_handcalcs()
