### A Pluto.jl notebook ###
# v0.19.40

using Markdown
using InteractiveUtils

# ╔═╡ 2f21b7c8-7f42-472d-96f4-4d3b2ef78c5d
# ╠═╡ show_logs = false
begin
	using Pkg
	Pkg.activate()
end;

# ╔═╡ 257c3540-08b3-11ef-2688-871bf1a3b81f
using Handcalcs, StructuralUnits, Format, LaTeXStrings, PlutoUI

# ╔═╡ 2ccedbb1-cfe9-4294-8e32-b10ecdabb6e9
set_default(fmt = x->format(round(x, digits=2)));

# ╔═╡ 768c676e-2ca1-40a7-9cc7-ab02125af78d
html"""
<style>
	mjx-container {
		text-align: left !important;
	}
</style>
"""

# ╔═╡ bb307f84-ffaa-4293-b0a7-e440bb2bbf3c
PlutoUI.TableOfContents()

# ╔═╡ f2775dba-c43d-49fd-ad16-8fd243c364ed
md"# Flexural Design Example"

# ╔═╡ 915b0bb4-244a-46e2-9b7c-111263a82aaf
md"""
## Example Problem
Determine the LRFD flexural design strength for a W10x12 beam with an unbraced length of 2 ft.
"""

# ╔═╡ 3d8da8cc-4377-41c3-94cc-f5d94b462c61
md"### 1. Determine if Section is Compact"

# ╔═╡ fe1f1d8f-79c4-4ad0-baff-5a10b716605d
λ_flange = 9.43;

# ╔═╡ 11318345-f4b4-4898-af47-eaa4271a6f1b
λ_web = 46.6;

# ╔═╡ 74f3c512-6234-4906-957d-96b4d26f28da
@handcalcs begin
    λ_flange; "AISC Table 1-1";
    λ_web; "AISC Table 1-1";
end

# ╔═╡ 1b9c0691-ef9f-46d7-9881-b7c6fcb5c908
md"### 2. Determine the limiting ratios (AISC Table B4.1b)"

# ╔═╡ ba2a2c13-6742-4334-ad80-13ecddc5a322
md"#### Check Flange"

# ╔═╡ 30a8e920-ea4d-46c0-b9c5-0d78d4c6fef4
E = 29000ksi;

# ╔═╡ a52091a1-66ee-46a8-b2d1-b7559cb8db2e
F_y = 50ksi;

# ╔═╡ b9c02f01-803e-4e96-9816-fb58c25e7f07
@handcalcs begin
    E
    F_y
    λ_pf = 0.38*√(E/F_y); "Case 10";
    λ_r = 1.0*√(E/F_y)
    # check = λ_pf < λ_flange < λ_r; "Noncompact Flange"
end

# ╔═╡ d0de0ebb-599f-4b95-90ba-a530e30728da
begin
	local color = "blue"
	local typ = "Noncompact Flange"
	local latex = @handcalc λ_pf < λ_flange < λ_r
	if λ_pf < λ_flange < λ_r
		latex = @handcalc λ_pf < λ_flange < λ_r
	elseif λ_flange > λ_r
		latex = @handcalc λ_flange > λ_r
		color = "red"
		typ = "Slender Flange"
	else
		latex = @handcalc λ_flange < λ_pf
		typ = "Compact Flange"
	end
	latex = latex[2:end-1]
	L"%$latex \;\;\; \therefore  \text{{\color{%$color} \ %$typ}}"
end

# ╔═╡ 8ba92d03-c178-4d9b-a853-78e74c67b793
md"#### Check web"

# ╔═╡ 1c56fb7e-2089-4de2-b02a-923fe98e68d1
@handcalcs begin
    λ_pw = 3.76*√(E/F_y); "Case 10";
    # check = λ_web < λ_pw; "Compact Web"
end

# ╔═╡ cb813d83-df89-458c-bb84-8096931855c7
begin
	local latex = @handcalc λ_web < λ_pw
	latex = latex[2:end-1]
	L"%$latex \;\;\; \therefore  \text{{\color{blue} \ Compact Web}}"
end

# ╔═╡ ff2438b8-d9cd-4661-acd1-b5ccd181645c
md"### 3. Calculate the LB strength with AISC Spec F3"

# ╔═╡ 235ec0c3-4c3d-47b0-b56a-c1c5d689b79c
S_x = 10.9inch^3;

# ╔═╡ 11ea0e49-15ec-4594-a0e2-c724fec41aa9
Z_x = 12.6inch^3;

# ╔═╡ 6cd7c56b-bda1-4e2e-b8c7-c3a49d9be086
@handcalcs begin
    S_x; "AISC Table 1-1";
    Z_x; "AISC Table 1-1";
end

# ╔═╡ 03f9390d-8c27-4e5d-83ce-7fe419faf4e0
begin 
	latex = @handcalcs begin
    M_p = F_y * Z_x
	end post = kip*ft
	M_p = M_p |> kip*ft
	latex
end
	

# ╔═╡ c28686fd-63c3-49a6-bd0f-6d91a628ac0f
begin
	local latex = @handcalcs begin
    	M_nLB = (M_p - (M_p - 0.7*F_y*S_x)*((λ_flange-λ_pf)/(λ_r-λ_pf)))
	end post = kip*ft len=:long
	M_nLB = M_nLB |> kip*ft
	latex
end
	

# ╔═╡ fb9a965c-b182-4cf4-a936-efb293f7f864
md"### 4. Calculate LTB strength with AISC spec F2.2"

# ╔═╡ c6763020-fe54-49cb-96f5-cc57baaa6b13
L_b = 2ft;

# ╔═╡ 04f77dd0-c36f-4ec8-b32f-96a32bb121e8
r_y = 0.785inch ;

# ╔═╡ 3ff894fc-8f1d-4b9f-9f35-e5d541986d0f
@handcalcs begin
    L_b
    r_y
end

# ╔═╡ 05c98224-3304-450f-872c-3c6acd3a328b
begin
	local latex = @handcalcs begin
    L_p = 1.76*r_y*√(E/F_y)
	end post = ft
	L_p = L_p |> ft
	latex
end
	

# ╔═╡ 82c814b2-a7b1-4412-9cc5-30dfc255a793
begin 
	local latex = @handcalc L_p > L_b
	latex = latex[2:end-1]
	L"%$latex \;\;\; \therefore  \text{{\color{blue} \ Full Plastic Behavior}}"
end

# ╔═╡ 8448a854-5ac6-49ba-81b8-d64d00108445
@handcalcs begin
    M_nLTB = M_p
end post=kip*ft

# ╔═╡ 7315f226-ebb8-4d60-a32d-896e77338ed3
md"### 5. Design Strength"

# ╔═╡ b1991dc2-7645-4ce1-bedd-b4aaa85ff8d9
@handcalcs begin 
    M_n = min(M_nLTB, M_nLB) 
    ϕ_b = 0.9
    ϕM_n = ϕ_b*M_n
end not_funcs=min

# ╔═╡ Cell order:
# ╟─2f21b7c8-7f42-472d-96f4-4d3b2ef78c5d
# ╟─257c3540-08b3-11ef-2688-871bf1a3b81f
# ╟─2ccedbb1-cfe9-4294-8e32-b10ecdabb6e9
# ╟─768c676e-2ca1-40a7-9cc7-ab02125af78d
# ╟─bb307f84-ffaa-4293-b0a7-e440bb2bbf3c
# ╟─f2775dba-c43d-49fd-ad16-8fd243c364ed
# ╟─915b0bb4-244a-46e2-9b7c-111263a82aaf
# ╟─3d8da8cc-4377-41c3-94cc-f5d94b462c61
# ╠═fe1f1d8f-79c4-4ad0-baff-5a10b716605d
# ╠═11318345-f4b4-4898-af47-eaa4271a6f1b
# ╟─74f3c512-6234-4906-957d-96b4d26f28da
# ╟─1b9c0691-ef9f-46d7-9881-b7c6fcb5c908
# ╟─ba2a2c13-6742-4334-ad80-13ecddc5a322
# ╠═30a8e920-ea4d-46c0-b9c5-0d78d4c6fef4
# ╠═a52091a1-66ee-46a8-b2d1-b7559cb8db2e
# ╟─b9c02f01-803e-4e96-9816-fb58c25e7f07
# ╟─d0de0ebb-599f-4b95-90ba-a530e30728da
# ╟─8ba92d03-c178-4d9b-a853-78e74c67b793
# ╟─1c56fb7e-2089-4de2-b02a-923fe98e68d1
# ╟─cb813d83-df89-458c-bb84-8096931855c7
# ╟─ff2438b8-d9cd-4661-acd1-b5ccd181645c
# ╠═235ec0c3-4c3d-47b0-b56a-c1c5d689b79c
# ╠═11ea0e49-15ec-4594-a0e2-c724fec41aa9
# ╟─6cd7c56b-bda1-4e2e-b8c7-c3a49d9be086
# ╟─03f9390d-8c27-4e5d-83ce-7fe419faf4e0
# ╟─c28686fd-63c3-49a6-bd0f-6d91a628ac0f
# ╟─fb9a965c-b182-4cf4-a936-efb293f7f864
# ╠═c6763020-fe54-49cb-96f5-cc57baaa6b13
# ╠═04f77dd0-c36f-4ec8-b32f-96a32bb121e8
# ╟─3ff894fc-8f1d-4b9f-9f35-e5d541986d0f
# ╟─05c98224-3304-450f-872c-3c6acd3a328b
# ╟─82c814b2-a7b1-4412-9cc5-30dfc255a793
# ╟─8448a854-5ac6-49ba-81b8-d64d00108445
# ╟─7315f226-ebb8-4d60-a32d-896e77338ed3
# ╟─b1991dc2-7645-4ce1-bedd-b4aaa85ff8d9
