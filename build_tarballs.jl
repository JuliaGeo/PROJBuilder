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
make -j2
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
    LibraryProduct(prefix, "libproj", :libproj)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, "PROJ", sources, script, platforms, products, dependencies)

