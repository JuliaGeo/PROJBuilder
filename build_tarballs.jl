using BinaryBuilder

src_version = v"5.2.0"  # also change in raw script string

# Collection of sources required to build PROJ
sources = [
    "http://download.osgeo.org/proj/proj-$src_version.tar.gz" =>
    "ef919499ffbc62a4aae2659a55e2b25ff09cccbbe230656ba71c6224056c7e60",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd proj-5.2.0/
./configure --prefix=$prefix --host=$target
make -j${nproc}
make install
"""

platforms = supported_platforms()

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libproj", :libproj),
    
    # complete contents of share/proj, must be kept up to date
    FileProduct(prefix, joinpath("share", "proj", "CH"), :ch_path),
    FileProduct(prefix, joinpath("share", "proj", "epsg"), :epsg_path),
    FileProduct(prefix, joinpath("share", "proj", "esri"), :esri_path),
    FileProduct(prefix, joinpath("share", "proj", "esri.extra"), :esri_extra_path),
    FileProduct(prefix, joinpath("share", "proj", "GL27"), :gl27_path),
    FileProduct(prefix, joinpath("share", "proj", "IGNF"), :ignf_path),
    FileProduct(prefix, joinpath("share", "proj", "nad27"), :nad27_path),
    FileProduct(prefix, joinpath("share", "proj", "nad83"), :nad83_path),
    FileProduct(prefix, joinpath("share", "proj", "nad.lst"), :nad_lst_path),
    FileProduct(prefix, joinpath("share", "proj", "other.extra"), :other_extra_path),
    FileProduct(prefix, joinpath("share", "proj", "proj_def.dat"), :proj_def_dat_path),
    FileProduct(prefix, joinpath("share", "proj", "world"), :world_path)
]

# Dependencies that must be installed before this package can be built
dependencies = []

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, "PROJ", src_version, sources, script, platforms, products, dependencies)
