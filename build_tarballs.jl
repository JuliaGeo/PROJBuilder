using BinaryBuilder

# Collection of sources required to build PROJ
sources = [
    "http://download.osgeo.org/proj/proj-4.9.3.tar.gz" =>
    "6984542fea333488de5c82eea58d699e4aff4b359200a9971537cd7e047185f7",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd proj-4.9.3/
./configure --prefix=$prefix --host=$target
make -j${nproc}
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    BinaryProvider.Linux(:i686, :glibc),
    BinaryProvider.Linux(:x86_64, :glibc),
    BinaryProvider.Linux(:aarch64, :glibc),
    BinaryProvider.Linux(:armv7l, :glibc),
    BinaryProvider.Linux(:powerpc64le, :glibc),
    BinaryProvider.MacOS(),
    BinaryProvider.Windows(:i686),
    BinaryProvider.Windows(:x86_64)
]

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
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, "PROJ", sources, script, platforms, products, dependencies)

