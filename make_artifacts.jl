using Tar, Inflate, SHA, TOML

artifacts = Dict()

folders = ["CrI3", "Si", "Si2"]

for folder in folders
  fullpath = joinpath("datasets", folder)
  isdir(fullpath) || continue
  outpath  = joinpath(pwd(),"artifacts","$folder.tar.gz")

  cd(fullpath) do
    run(`tar -cvzf $outpath $(readdir())`)
  end

  artifact_name = folder
  artifacts[folder] = Dict(
      "git-tree-sha1" => Tar.tree_hash(IOBuffer(inflate_gzip(outpath))),
      "lazy" => true,
      "download" => [Dict(
      "url" => "https://github.com/Koulb/QuantumEspressoDatasets/raw/main/artifacts/$(folder).tar.gz",
      "sha256" => bytes2hex(open(sha256, outpath)))]
    )
end

open("Artifacts.toml", "w") do io
    TOML.print(io, artifacts)
end
