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


# use set_handcalcs for not_funcs
# ***************************************************
# ***************************************************
set_handcalcs(not_funcs = [:calc_Ix])

expected = L"$\begin{aligned}
Ix &= \mathrm{calc}_{Ix}\left( 5, 15 \right) = 1406.25
\end{aligned}$"

calc = @handcalcs Ix = calc_Ix(5, 15)
@test calc == expected
reset_handcalcs()


# use set_handcalcs for precision
# ***************************************************
# ***************************************************
set_handcalcs(precision = 1)

expected =L"\begin{aligned}
x &= 5.3
\\[10pt]
y &= 4
\end{aligned}"

calc = @handcalcs begin
    x = 5.25
    y = 4
end
@test calc == expected

# make sure default precision does not overwrite given values
expected =L"\begin{aligned}
x &= 5.2565
\\[10pt]
y &= 4
\end{aligned}"

calc = @handcalcs begin
    x = 5.25645
    y = 4
end precision = 4
@test calc == expected


expected =L"\begin{aligned}
x &= 5.2565
\\[10pt]
y &= 4.0000
\end{aligned}"

calc = @handcalcs begin
    x = 5.25645
    y = 4
end fmt = "%.4f"
@test calc == expected
reset_handcalcs()


# use set_handcalcs for h_render
# ***************************************************
# ***************************************************

# symbolic return
set_handcalcs(h_render = :symbolic)
expected = L"$\begin{aligned}
c &= a + b = 15
\end{aligned}$"

a = 5
b = 10

calc = @handcalcs begin
    c = a + b
end
@test calc == expected
reset_handcalcs()

# numeric return
set_handcalcs(h_render = :numeric)
expected = L"$\begin{aligned}
c &= 5 + 10 = 15
\end{aligned}$"

calc = @handcalcs begin
    c = a + b
end h_render = :numeric
@test calc == expected
reset_handcalcs()
