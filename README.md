# Test Boost.Python on Android

Output:

    Hello from test.cpp!
    Hello from main.py!
    Hello from my_native_py.cpp!

## How to build, install and run

    make && make install && make run

You can also `make help` for a explanation of the `make` targets.
`make` or `make ndk-build` compiles and links the files in `jni/`.
`make install` pushes assets, python and outputs of `ndk-build` on the device
into /data/local/tmp/test-boost-python-3.
It creates a `install` cache for incrementally updating files on the device.
`make run` runs the executable `test-boost-python-3` on the device.
`make clean` removes everything execept the `install` cache.
`make uninstall` removes the `install` cache and removes the project folder
on the device.

`ndk-build` needs to be in PATH.
CrystaX NDK dependencies:

    arm-linux-androideabi-5-linux-x86_64.tar.xz
    boost-1.59.0-build-files.tar.xz
    boost-1.59.0-headers.tar.xz
    boost-1.59.0-libs-gnu-5-armeabi.tar.xz
    compiler-rt-libs-armeabi.tar.xz             # don't know
    crystax-libs-armeabi.tar.xz
    gabixx-libs-armeabi-g.tar.xz                # don't know
    gnu-libstdc++-headers-5.tar.xz
    gnu-libstdc++-libs-5-armeabi-g.tar.xz
    libgccunwind-libs-armeabi.tar.xz
    python3.5-headers.tar.xz
    python3.5-libs-armeabi.tar.xz
