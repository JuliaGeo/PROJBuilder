using BinaryBuilder

src_version = v"6.1.0"  # also change below in script

# Collection of sources required to build PROJ
sources = [
    "http://download.osgeo.org/proj/proj-$src_version.tar.gz" =>
    "676165c54319d2f03da4349cbd7344eb430b225fe867a90191d848dc64788008",
]


# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd proj-6.1.0

# sqlite needed to build proj.db, so this should not be the
# cross-compiled one since it needs to be executed on the host
apk add sqlite

if [[ ${target} == *mingw* ]]; then
    SQLITE3_LIBRARY=$prefix/bin/libsqlite3-0.dll
elif [[ ${target} == *darwin* ]]; then
    SQLITE3_LIBRARY=$prefix/lib/libsqlite3.dylib
else
    SQLITE3_LIBRARY=$prefix/lib/libsqlite3.so
fi

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$prefix \
      -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain \
      -DSQLITE3_INCLUDE_DIR=$prefix/include \
      -DSQLITE3_LIBRARY=$SQLITE3_LIBRARY \
      -DHAVE_PTHREAD_MUTEX_RECURSIVE_DEFN=1 \
      -DBUILD_LIBPROJ_SHARED=ON \
      ..
cmake --build .
make install

# add proj-datumgrid files directly to the result
wget https://download.osgeo.org/proj/proj-datumgrid-1.8.tar.gz
tar xzf proj-datumgrid-1.8.tar.gz -C $prefix/share/proj/
"""

platforms = supported_platforms()
platforms = expand_gcc_versions(platforms)

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libproj", :libproj),

    ExecutableProduct(prefix, "cct", :cct_path),
    ExecutableProduct(prefix, "cs2cs", :cs2cs_path),
    ExecutableProduct(prefix, "geod", :geod_path),
    ExecutableProduct(prefix, "gie", :gie_path),
    ExecutableProduct(prefix, "proj", :proj_path),
    ExecutableProduct(prefix, "projinfo", :projinfo_path),

    # complete contents of share/proj, must be kept up to date
    FileProduct(prefix, joinpath("share", "proj", "CH"), :ch_path),
    FileProduct(prefix, joinpath("share", "proj", "GL27"), :gl27_path),
    FileProduct(prefix, joinpath("share", "proj", "ITRF2000"), :itrf2000_path),
    FileProduct(prefix, joinpath("share", "proj", "ITRF2008"), :itrf2008_path),
    FileProduct(prefix, joinpath("share", "proj", "ITRF2014"), :itrf2014_path),
    FileProduct(prefix, joinpath("share", "proj", "nad.lst"), :nad_lst_path),
    FileProduct(prefix, joinpath("share", "proj", "nad27"), :nad27_path),
    FileProduct(prefix, joinpath("share", "proj", "nad83"), :nad83_path),
    FileProduct(prefix, joinpath("share", "proj", "null"), :null_path),
    FileProduct(prefix, joinpath("share", "proj", "other.extra"), :other_extra_path),
    FileProduct(prefix, joinpath("share", "proj", "proj.db"), :proj_db_path),
    FileProduct(prefix, joinpath("share", "proj", "world"), :world_path),

    # part of files from proj-datumgrid which are added to the default ones
    # all are added but only the few below are checked if they are added
    # note that none of proj-datumgrid-europe, proj-datumgrid-north-america,
    # proj-datumgrid-oceania, proj-datumgrid-world is added by default,
    # though users are free to add them to the rest themselves
    FileProduct(prefix, joinpath("share", "proj", "alaska"), :alaska_path),
    FileProduct(prefix, joinpath("share", "proj", "conus"), :conus_path),
    FileProduct(prefix, joinpath("share", "proj", "egm96_15.gtx"), :egm96_15_path),
    FileProduct(prefix, joinpath("share", "proj", "ntv1_can.dat"), :ntv1_can_path),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/JuliaDatabases/SQLiteBuilder/releases/download/v0.10.0/build_SQLite.v3.28.0.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, "PROJ", src_version, sources, script, platforms, products, dependencies)
