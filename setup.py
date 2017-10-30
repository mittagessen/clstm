#!/usr/bin/env python

import os
from setuptools import setup
from setuptools.extension import Extension
from setuptools.command.build_ext import build_ext as _build_ext
from setuptools.command.install import install

from distutils.command.build import build


# hgversion = os.popen("hg -q id").read().strip()
hgversion = "unknown"

print "making proto file"
os.system("protoc clstm.proto --cpp_out=.")

class CustomBuild(build):
    def run(self):
        self.run_command('build_ext')
        build.run(self)

class CustomInstall(install):
    def run(self):
        self.run_command('build_ext')
        self.do_egg_install()

class build_ext(_build_ext):
    def finalize_options(self):
        _build_ext.finalize_options(self)
        # Prevent numpy from thinking it is still in its setup process:
        __builtins__.__NUMPY_SETUP__ = False
        import numpy
        self.include_dirs.append(numpy.get_include())
        self.swig_opts.extend(["-c++"] + ["-I" + d for d in self.include_dirs])

clstm = Extension('_clstm',
        libraries = ['png','protobuf'],
        include_dirs = ['/usr/include/eigen3', '/usr/local/include/eigen3', '/usr/local/include', '/usr/include/hdf5/serial'],
        extra_compile_args = ['-std=c++11','-w',
            '-Dadd_raw=add','-DNODISPLAY=1','-DTHROW=throw',
            '-DHGVERSION="\\"'+hgversion+'\\""'],
        sources=['clstm.i','clstm.cc','clstm_prefab.cc','extras.cc',
                 'ctc.cc','clstm_proto.cc','clstm.pb.cc'])

try:
    import numpy
    setup_requires = []
except ImportError:
    setup_requires = ['numpy']

setup (name = 'clstm',
       version = '0.0.11',
       author      = "Thomas Breuel",
       description = """clstm library bindings""",
       ext_modules = [clstm],
       py_modules = ["clstm"],
       cmdclass={'build': CustomBuild, 'install': CustomInstall, 'build_ext':build_ext},
       setup_requires=setup_requires,
       install_requires = ['numpy'])
