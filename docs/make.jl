using RandomParticles
using Documenter

DocMeta.setdocmeta!(RandomParticles, :DocTestSetup, :(using RandomParticles); recursive=true)

makedocs(;
    modules=[RandomParticles],
    authors="Gabriel Wu <wuzihua@pku.edu.cn> and contributors",
    repo="https://github.com/JuliaRemoteSensing/RandomParticles.jl/blob/{commit}{path}#{line}",
    sitename="RandomParticles.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://JuliaRemoteSensing.github.io/RandomParticles.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/JuliaRemoteSensing/RandomParticles.jl",
    devbranch="main",
)
