#cython: boundscheck=False
#cython: wraparound=False
#cython: optimize.use_switch=True
#cython: optimize.unpack_method_calls=True
# -*- coding: utf-8 -*-
"""
cutil.pyx

Created by Stephan Hügel on 2016-08-08

This file is part of simplification.

The MIT License (MIT)

Copyright (c) 2016 Stephan Hügel

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

"""
__author__ = u"Stephan Hügel"

from libc.stdlib cimport malloc, free
from rdp_p cimport (
    ExternalArray,
    InternalArray,
    simplify_rdp_ffi,
    simplify_rdp_idx_ffi,
    simplify_visvalingam_ffi,
    simplify_visvalingam_idx_ffi,
    simplify_visvalingamp_ffi,
    drop_float_array,
    drop_usize_array,
)

numpy_installed = True
try:
    import numpy as np
except ImportError:
    numpy_installed = False


ctypedef InternalArray(*f_type)(ExternalArray, double)


cdef ExternalArray __coords_to_external_array(coords, use_numpy):
    cdef ExternalArray coords_ffi
    cdef double[:,::1] ncoords
    if use_numpy:
        arr = np.array(coords, dtype=np.float64)
        if not arr.flags['C_CONTIGUOUS']:
            arr = np.ascontiguousarray(arr)
        ncoords = np.array(arr, dtype=np.float64)
        coords_ffi.data = <void*>&ncoords[0, 0]
        coords_ffi.len = ncoords.shape[0]
    else:
        coords_ptr = <double *> malloc(2 * len(coords) * sizeof(double))
        if not coords_ptr:
            raise MemoryError()
        for i, (x, y) in enumerate(coords):
            coords_ptr[2 * i] = x
            coords_ptr[2 * i + 1] = y
        coords_ffi.data = coords_ptr
        coords_ffi.len = len(coords)
    return coords_ffi


cdef __simplify(f_type method, coords, double epsilon):
    if not len(coords):
        return coords
    cdef InternalArray result
    cdef double * incoming_ptr
    cdef double[:, ::1] view
    use_numpy = numpy_installed and isinstance(coords, np.ndarray)
    cdef ExternalArray coords_ffi = __coords_to_external_array(coords, use_numpy)
    try:
        result = method(coords_ffi, epsilon)
        incoming_ptr = <double*>(result.data)
        view = <double[:result.len,:2:1]>incoming_ptr
        try:
            if use_numpy:
                outgoing = np.copy(view)
            else:
                outgoing = [list(row) for row in view]
            return outgoing
        finally:
            drop_float_array(result)
    finally:
        if not use_numpy:
            free(<void*>coords_ffi.data)


cdef __simplify_idx(f_type method, coords, double epsilon):
    if not len(coords):
        return coords
    cdef InternalArray result
    cdef size_t * incoming_ptr
    cdef size_t[::1] view
    use_numpy = numpy_installed and isinstance(coords, np.ndarray)
    cdef ExternalArray coords_ffi = __coords_to_external_array(coords, use_numpy)
    try:
        result = method(coords_ffi, epsilon)
        incoming_ptr = <size_t*>(result.data)
        view = <size_t[:result.len]>incoming_ptr
        try:
            if use_numpy:
                outgoing = np.copy(view)
            else:
                outgoing = list(view)
            return outgoing
        finally:
            drop_usize_array(result)
    finally:
        if not use_numpy:
            free(<void*>coords_ffi.data)


cpdef simplify_coords(coords, double epsilon):
    """
    Simplify a LineString using the Douglas-Ramer-Peucker algorithm.
    Input: a list of lat, lon coordinates, and an epsilon float (Try 1.0 to begin with, reducing by orders of magnitude)
    Output: a simplified list of coordinates

    Example: simplify_coords([
        [0.0, 0.0], [5.0, 4.0], [11.0, 5.5], [17.3, 3.2], [27.8, 0.1]],
        1.0)
    Result: [[0.0, 0.0], [5.0, 4.0], [11.0, 5.5], [27.8, 0.1]]

    """
    return __simplify(simplify_rdp_ffi, coords, epsilon)


cpdef simplify_coords_idx(coords, double epsilon):
    """
    Simplify a LineString using the Douglas-Ramer-Peucker algorithm.
    Input: a list of lat, lon coordinates, and an epsilon float (Try 1.0 to begin with, reducing by orders of magnitude)
    Output: a simplified list of coordinate indices

    Example: simplify_coords_idx([
        [0.0, 0.0], [5.0, 4.0], [11.0, 5.5], [17.3, 3.2], [27.8, 0.1]],
        1.0)
    Result: [0, 1, 2, 4]

    """
    return __simplify_idx(simplify_rdp_idx_ffi, coords, epsilon)


cpdef simplify_coords_vw(coords, double epsilon):
    """
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
    return __simplify(simplify_visvalingam_ffi, coords, epsilon)


cpdef simplify_coords_vw_idx(coords, double epsilon):
    """
    Simplify a LineString using the Visvalingam-Whyatt algorithm.
    Input: a list of lat, lon coordinates, and an epsilon float
    Output: a simplified list of coordinate indices

    Example: simplify_coords_vw_idx([
        [0.0, 0.0], [5.0, 4.0], [11.0, 5.5], [17.3, 3.2], [27.8, 0.1]],
        1.0)
    Result: [0, 1, 2, 4]

    """
    return __simplify_idx(simplify_visvalingam_idx_ffi, coords, epsilon)


cpdef simplify_coords_vwp(coords, double epsilon):
    """
    Simplify a LineString using a topology-preserving variant of the
    Visvalingam-Whyatt algorithm.
    Input: a list of lat, lon coordinates, and an epsilon float
    Output: a simplified list of coordinates

    Example:
    simplify_coords_vwp([
        [5.0, 2.0], [3.0, 8.0], [6.0, 20.0], [7.0, 25.0], [10.0, 10.0]],
        30.0
    )
    Result: [[5.0, 2.0], [7.0, 25.0], [10.0, 10.0]]

    """
    return __simplify(simplify_visvalingamp_ffi, coords, epsilon)
