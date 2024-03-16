### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ ab72ba8c-b356-11ee-0a39-0d1b38e5f4ca
# ╠═╡ show_logs = false
begin
	using Revise, Pkg
	Pkg.activate();
end

# ╔═╡ ce5b3335-daca-45cc-82bb-6a05ec02e9a5
using Handcalcs, Latexify, LaTeXStrings, CodeTracking, BridgeCalcsUS

# ╔═╡ 02f3158c-59a5-4282-88d4-35c4551c0033
using Unitful, UnitfulLatexify, DataFrames

# ╔═╡ 59d2b9f7-1601-478a-99dc-e54f7166aafa
using PlutoTeachingTools, PlutoUI; TableOfContents()

# ╔═╡ af2113ee-0352-4b65-a269-723450ba54ea
using CairoMakie

# ╔═╡ 1bc35d4c-9391-4459-b961-d7b608324790
const inch = u"inch";

# ╔═╡ 8de622aa-5a8a-4761-8f58-b651d1ae04b6
md"""
# Handcalc Demo
"""

# ╔═╡ ff37c719-5e6e-44f6-8a7c-b15a4a04ffc5
md"## Input Cells"

# ╔═╡ 2b3ad300-c287-47eb-a80c-3d6140ad13f3
a = 2*inch;

# ╔═╡ f070d246-1dba-415b-a498-81f8207f79a2
b = -5*inch;

# ╔═╡ 5c94ae24-3346-48e5-aff3-18140a2967fb
c = 2*inch;

# ╔═╡ a14751cd-1ec4-4620-bc4b-e19abb50bb32
h = 15*inch;

# ╔═╡ dc918ecf-23b1-49f0-8976-a3986d06e522
md"""
## Latex Formula
"""

# ╔═╡ a7e0bd67-96f9-4d6d-895b-62be07deb9d1
md("##### Quadratic Formula:")

# ╔═╡ 7ade629c-5382-48b0-a70e-b5482f21a89d
@handcalc begin x = (-b - sqrt(b^2 - 4*a*c))/(2*a) end

# ╔═╡ f4c40265-adf0-4257-a953-73b2bee8974c
begin
	if x > 0
		TwoColumnWideLeft(md"",correct(md"x = $x is greater than 0"))
	else 
		TwoColumnWideLeft(md"",danger(md"x = $x is less than or equal to 0"))
	end
end

# ╔═╡ ef7ad156-0f24-4594-857e-df3635b06af6
begin
	if x > 0
		html"<p style='text-align: right;'><span style='font-family: bold; color: green;'>Value is OK</span></p>"
	else 
		html"<p style='text-align: right;'><span style='font-family: bold; color: red;'>Value is NG</span></p>"
	end

	

end

# ╔═╡ a156a574-e767-46a7-9885-27d698663135
begin @handcalc d = (a + b) * c end

# ╔═╡ bf091ac0-adce-42af-8be5-fe76fa70b3dc
begin @latexdefine e = ($a + $b) * $c end

# ╔═╡ de809996-e677-4c59-adcd-4697dc423965
@latexdefine begin f = (-$b + sqrt($b^2 - 4*$a*$c))/(2*$a) end

# ╔═╡ d35d01cd-7a80-4b3b-a64c-8dab2231d82b
@handcalc begin Ix = calculate_Ix(b, h) end

# ╔═╡ 2ce0e082-7235-4bb0-99ef-fd32b29782e6
@handcalc begin IIx = b*h^3/12 end

# ╔═╡ fb872702-2762-4542-9ac5-0b8809f5ebfd
@handcalcs begin
	IIy = h*b^3/12; "moment of inertia";
	IIIx = b*h^3/12; "AASHTO 5.6.2";
end

# ╔═╡ aa1131ee-fcf9-44b2-9d65-09bdeccb1e0c
@handfunc begin Iy=calculate_Ix(b, h) end

# ╔═╡ defc22d4-4de6-4c6a-b60c-9ae937999c15
md"### Table Example"

# ╔═╡ 8d93b4ff-c972-47ad-b73c-a8691b32a442
begin df = DataFrame(Dict(
	"Height" => [2*inch, 4*inch, 6*inch], 
	"Width" => [1*inch, 3*inch, 5*inch]
)) 
end

# ╔═╡ fe5a8486-87e1-46db-9ce4-adfca8b10a12
md"### Plot Example"

# ╔═╡ 4cc30f06-9b65-425a-a238-741b64a139c5
y = -1000:50:1000;

# ╔═╡ b60b54c6-9a6f-4da5-9235-9e7c80c5f6af
z = y.^3;

# ╔═╡ bde76f18-f5a5-4e05-8e8c-ac931c231743
# begin
# 	lines(y, z)
# 	scatter!(y, z)
# end

# ╔═╡ 04f5fe71-fff8-4cc8-80c3-c978977eca05
begin
	fig, ax, l1 = lines(y, z)
	s1 = scatter!(y, z)
	ax.xlabel = "x label"
	ax.ylabel = "y label"
	ax.title = "Polynomial Plot"
	fig
end

# ╔═╡ 998a6b3c-fb16-4f67-8666-a1112bd3b5e3
arg = "AASHTO 5.6.2"

# ╔═╡ 54c0b498-7a10-4baf-aa13-881407826b5c


# ╔═╡ Cell order:
# ╠═ab72ba8c-b356-11ee-0a39-0d1b38e5f4ca
# ╠═ce5b3335-daca-45cc-82bb-6a05ec02e9a5
# ╠═02f3158c-59a5-4282-88d4-35c4551c0033
# ╠═59d2b9f7-1601-478a-99dc-e54f7166aafa
# ╠═1bc35d4c-9391-4459-b961-d7b608324790
# ╠═af2113ee-0352-4b65-a269-723450ba54ea
# ╟─8de622aa-5a8a-4761-8f58-b651d1ae04b6
# ╟─ff37c719-5e6e-44f6-8a7c-b15a4a04ffc5
# ╠═2b3ad300-c287-47eb-a80c-3d6140ad13f3
# ╠═f070d246-1dba-415b-a498-81f8207f79a2
# ╠═5c94ae24-3346-48e5-aff3-18140a2967fb
# ╠═a14751cd-1ec4-4620-bc4b-e19abb50bb32
# ╟─dc918ecf-23b1-49f0-8976-a3986d06e522
# ╟─a7e0bd67-96f9-4d6d-895b-62be07deb9d1
# ╟─7ade629c-5382-48b0-a70e-b5482f21a89d
# ╟─f4c40265-adf0-4257-a953-73b2bee8974c
# ╟─ef7ad156-0f24-4594-857e-df3635b06af6
# ╟─a156a574-e767-46a7-9885-27d698663135
# ╟─bf091ac0-adce-42af-8be5-fe76fa70b3dc
# ╟─de809996-e677-4c59-adcd-4697dc423965
# ╟─d35d01cd-7a80-4b3b-a64c-8dab2231d82b
# ╟─2ce0e082-7235-4bb0-99ef-fd32b29782e6
# ╟─fb872702-2762-4542-9ac5-0b8809f5ebfd
# ╟─aa1131ee-fcf9-44b2-9d65-09bdeccb1e0c
# ╟─defc22d4-4de6-4c6a-b60c-9ae937999c15
# ╟─8d93b4ff-c972-47ad-b73c-a8691b32a442
# ╟─fe5a8486-87e1-46db-9ce4-adfca8b10a12
# ╠═4cc30f06-9b65-425a-a238-741b64a139c5
# ╠═b60b54c6-9a6f-4da5-9235-9e7c80c5f6af
# ╟─bde76f18-f5a5-4e05-8e8c-ac931c231743
# ╟─04f5fe71-fff8-4cc8-80c3-c978977eca05
# ╠═998a6b3c-fb16-4f67-8666-a1112bd3b5e3
# ╠═54c0b498-7a10-4baf-aa13-881407826b5c
