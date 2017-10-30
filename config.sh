# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.
    if [ -n "$IS_OSX" ]; then
        export CC=clang
        export CXX=clang++
        export CFLAGS="-fPIC -O3 -arch i386 -arch x86_64 -g -DNDEBUG -mmacosx-version-min=10.6"
        brew tap homebrew/science
        brew update
        brew install swig # automake
    else
        yum install -y pcre-devel libpng-devel libpng
	yum install -y automake
        curl -O -L http://downloads.sourceforge.net/swig/swig-3.0.10.tar.gz
        tar xzf swig-3.0.10.tar.gz
        (cd swig-3.0.10 \
				&& ./configure --prefix=$BUILD_PREFIX \
				&& make \
				&& make install)
	curl -O -L https://github.com/google/protobuf/archive/v3.4.1.tar.gz
	tar xzf v3.4.1.tar.gz
	(cd protobuf-3.4.1 \
		&& ./autogen.sh \
		&& ./configure --prefix=$BUILD_PREFIX \
		&& make \
		&& make install)
	pip install numpy
	curl -O -L http://bitbucket.org/eigen/eigen/get/3.3.4.tar.bz2
	tar xvf 3.3.4.tar.bz2
	(cd eigen-eigen-5a0156e40feb \
		&& mkdir /usr/include/eigen3 \
		&& cp -R Eigen /usr/include/eigen3)
    fi
}

function build_wheel {
    # Set default building method to pip
    build_bdist_wheel $@
    # setup.py sdist fails with
    # error: [Errno 2] No such file or directory: 'venv/lib/python3.5/_dummy_thread.py'
    # for python less than 3.5
    if [[ `python -c 'import sys; print(sys.version.split()[0] >= "3.6.0")'` == "True" ]]; then
        python setup.py sdist --dist-dir $(abspath ${WHEEL_SDIR:-wheelhouse})
    else
        echo "skip sdist"
    fi
}

function run_tests {
	:
}
