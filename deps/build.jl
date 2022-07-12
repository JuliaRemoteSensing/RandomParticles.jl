using Libdl: dlopen, dlclose

cd(joinpath("..", "fortran"))

librsgen = if Sys.iswindows()
    "librsgen.dll"
elseif Sys.islinux()
    "librsgen.so"
else
    "librsgen.dylib"
end

run(`gfortran -O3 -shared -fPIC -funroll-loops -o $librsgen random_sphere_gen.f90`)
if !isdir(joinpath("..", "shared"))
    mkdir(joinpath("..", "shared"))
end
mv(librsgen, joinpath("..", "shared", librsgen), force=true)
rm("intrinsics.mod", force=true)
rm("mpidefs.mod", force=true)
rm("random_sphere_configuration.mod", force=true)

if Sys.iswindows()
    try 
        dlclose(dlopen(joinpath("..", "shared", librsgen)))
    catch e
        error("64-bit gfortran is required to build this package on Windows.")
    end
end
