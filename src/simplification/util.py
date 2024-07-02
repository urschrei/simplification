# -*- coding: utf-8 -*-
"""
ffi.py

Created by Stephan Hügel on 2016-08-3

This file is part of simplification.
"""

import os
from ctypes import POINTER, Structure, c_double, c_size_t, c_void_p, cast, cdll
from sys import platform, version_info

numpy_installed = True
try:
    import numpy as np
except ImportError:
    numpy_installed = False

__author__ = "Stephan Hügel"
file_path = os.path.dirname(__file__)

prefix = {"win32": ""}.get(platform, "lib")
extension = {"darwin": ".dylib", "win32": ".dll"}.get(platform, ".so")
fpath = {"darwin": "", "win32": ""}.get(platform, os.path.join(file_path, ".libs"))

# Python 3 check
if version_info > (3, 0):
    from subprocess import getoutput as spop

    py3 = True
else:
    from subprocess import check_output as spop

    py3 = False

try:
    lib = cdll.LoadLibrary(os.path.join(file_path, prefix + "rdp" + extension))
except OSError:
    # the Rust lib's been grafted by manylinux1
    if not py3:
        fname = spop(["ls", fpath]).split()[0]
    else:
        fname = spop(["ls %s" % fpath]).split()[0]
    lib = cdll.LoadLibrary(os.path.join(file_path, ".libs", fname))


class _FFIArray(Structure):
    """
    Convert sequence of float lists to a C-compatible void array
    example: [[1.0, 2.0], [3.0, 4.0]]

    """

    _fields_ = [("data", c_void_p), ("len", c_size_t)]

    @classmethod
    def from_param(cls, seq):
        """Allow implicit conversions"""
        return seq if isinstance(seq, cls) else cls(seq)

    # noinspection PyPep8Naming
    def __init__(self, seq, data_type=c_double):
        if numpy_installed:
            self.data = cast(
                np.array(seq, dtype=np.float64).ctypes.data_as(POINTER(data_type)),
                c_void_p,
            )
        else:
            Coords = data_type * (2 * len(seq))
            arr = Coords(*[item for sublist in seq for item in sublist])
            self.data = cast(arr, c_void_p)
        self.len = len(seq)


class _CoordResult(Structure):
    """Container for returned FFI coordinate data"""

    _fields_ = [("coords", _FFIArray)]


def _void_array_to_nested_list(res, _func, _args):
    """Dereference the FFI result to a list of coordinates"""
    try:
        ptr = cast(res.coords.data, POINTER(c_double))
        if numpy_installed:
            shape = res.coords.len, 2
            array = np.ctypeslib.as_array(ptr, shape)
            return array.tolist()
        else:
            return list(
                zip(ptr[0 : res.coords.len * 2 : 2], ptr[1 : res.coords.len * 2 : 2])
            )
    finally:
        drop_array(res.coords)


simplify_coords = lib.simplify_rdp_ffi
simplify_coords.argtypes = (_FFIArray, c_double)
simplify_coords.restype = _CoordResult
simplify_coords.errcheck = _void_array_to_nested_list
simplify_coords.__doc__ = """
    Simplify a LineString using the Ramer-Douglas-Peucker algorithm.
    Input: a list of lat, lon coordinates, and an epsilon float (Try 1.0 to begin with,
    reducing by orders of magnitude)
    Output: a simplified list of coordinates

    Example:
    simplify_coords([
        [0.0, 0.0], [5.0, 4.0], [11.0, 5.5], [17.3, 3.2], [27.8, 0.1]],
        1.0
    )
    Result: [[0.0, 0.0], [5.0, 4.0], [11.0, 5.5], [27.8, 0.1]]

    """

simplify_coords_vw = lib.simplify_visvalingam_ffi
simplify_coords_vw.argtypes = (_FFIArray, c_double)
simplify_coords_vw.restype = _CoordResult
simplify_coords_vw.errcheck = _void_array_to_nested_list
simplify_coords_vw.__doc__ = """
    Simplify a LineString using the Visvalingam-Whyatt algorithm.
    Input: a list of lat, lon coordinates, and an epsilon float
    Output: a simplified list of coordinates

    Example:
    simplify_coords_vw([
        [5.0, 2.0], [3.0, 8.0], [6.0, 20.0], [7.0, 25.0], [10.0, 10.0]],
        30.0
    )
    Result: [[5.0, 2.0], [7.0, 25.0], [10.0, 10.0]]

    """

simplify_coords_vwp = lib.simplify_visvalingamp_ffi
simplify_coords_vwp.argtypes = (_FFIArray, c_double)
simplify_coords_vwp.restype = _CoordResult
simplify_coords_vwp.errcheck = _void_array_to_nested_list
simplify_coords_vwp.__doc__ = """
    Simplify a LineString using a topology-preserving variant of
    the Visvalingam-Whyatt algorithm.
    Input: a list of lat, lon coordinates, and an epsilon float
    Output: a simplified list of coordinates

    Example:
    simplify_coords_vwp([
        [5.0, 2.0], [3.0, 8.0], [6.0, 20.0], [7.0, 25.0], [10.0, 10.0]],
        30.0
    )
    Result: [[5.0, 2.0], [7.0, 25.0], [10.0, 10.0]]

    """

drop_array = lib.drop_float_array
drop_array.argtypes = (_FFIArray,)
drop_array.restype = None
