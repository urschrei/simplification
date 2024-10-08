#cython: boundscheck=False
#cython: wraparound=False
#cython: optimize.use_switch=True
#cython: optimize.unpack_method_calls=True
# -*- coding: utf-8 -*-
"""
cutil.pyx

Created by Stephan Hügel on 2016-08-08

This file is part of simplification.
"""
__author__ = u"Stephan Hügel"

import numpy as np
import numpy
from cython cimport view
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
    if not len(coords):
        return coords
    arr = np.array(coords, dtype=np.float64)
    if not arr.flags['C_CONTIGUOUS']:
        arr = np.ascontiguousarray(arr)
    cdef double[:,::1] ncoords = np.array(arr, dtype=np.float64)
    cdef ExternalArray coords_ffi
    coords_ffi.data = <void*>&ncoords[0, 0]
    coords_ffi.len = ncoords.shape[0]
    cdef InternalArray result = simplify_rdp_ffi(coords_ffi, epsilon)
    cdef double* incoming_ptr = <double*>(result.data)
    cdef double[:, ::1] view = <double[:result.len,:2:1]>incoming_ptr
    if isinstance(coords, numpy.ndarray):
        outgoing = np.copy(view)
    else:
        outgoing = np.copy(view).tolist()
    try:
        return outgoing
    finally:
        drop_float_array(result)

cpdef simplify_coords_idx(coords, double epsilon):
    """
    Simplify a LineString using the Douglas-Ramer-Peucker algorithm.
    Input: a list of lat, lon coordinates, and an epsilon float (Try 1.0 to begin with, reducing by orders of magnitude)
    Output: a simplified list of coordinate indices

    Example: simplify_coords([
        [0.0, 0.0], [5.0, 4.0], [11.0, 5.5], [17.3, 3.2], [27.8, 0.1]],
        1.0)
    Result: [[0.0, 0.0], [5.0, 4.0], [11.0, 5.5], [27.8, 0.1]]

    """
    if not len(coords):
        return coords
    cdef double[:,::1] ncoords = np.array(coords, dtype=np.float64)
    cdef ExternalArray coords_ffi
    coords_ffi.data = <void*>&ncoords[0, 0]
    coords_ffi.len = ncoords.shape[0]
    cdef InternalArray result = simplify_rdp_idx_ffi(coords_ffi, epsilon)
    cdef size_t* incoming_ptr = <size_t*>(result.data)
    cdef size_t[::1] view = <size_t[:result.len]>incoming_ptr
    if isinstance(coords, numpy.ndarray):
        outgoing = np.copy(view)
    else:
        outgoing = np.copy(view).tolist()
    try:
        return outgoing
    finally:
        drop_usize_array(result)

cpdef simplify_coords_vw(coords, double epsilon):
    """
    Simplify a LineString using the Visvalingam-Whyatt algorithm.
    Input: a list of lat, lon coordinates, and an epsilon float
    Output: a simplified list of coordinates

    Example:
    simplify_coords([
        [5.0, 2.0], [3.0, 8.0], [6.0, 20.0], [7.0, 25.0], [10.0, 10.0]],
        30.0
    )
    Result: [[5.0, 2.0], [7.0, 25.0], [10.0, 10.0]]

    """
    if not len(coords):
        return coords
    cdef double[:,::1] ncoords = np.array(coords, dtype=np.float64)
    cdef ExternalArray coords_ffi
    coords_ffi.data = <void*>&ncoords[0, 0]
    coords_ffi.len = ncoords.shape[0]
    cdef InternalArray result = simplify_visvalingam_ffi(coords_ffi, epsilon)
    cdef double* incoming_ptr = <double*>(result.data)
    cdef double[:, ::1] view = <double[:result.len,:2:1]>incoming_ptr
    if isinstance(coords, numpy.ndarray):
        outgoing = np.copy(view)
    else:
        outgoing = np.copy(view).tolist()
    try:
        return outgoing
    finally:
        drop_float_array(result)

cpdef simplify_coords_vw_idx(coords, double epsilon):
    """
    Simplify a LineString using the Visvalingam-Whyatt algorithm.
    Input: a list of lat, lon coordinates, and an epsilon float
    Output: a simplified list of coordinate indices

    Example: simplify_coords([
        [0.0, 0.0], [5.0, 4.0], [11.0, 5.5], [17.3, 3.2], [27.8, 0.1]],
        1.0)
    Result: [[0.0, 0.0], [5.0, 4.0], [11.0, 5.5], [27.8, 0.1]]

    """
    if not len(coords):
        return coords
    cdef double[:,::1] ncoords = np.array(coords, dtype=np.float64)
    cdef ExternalArray coords_ffi
    coords_ffi.data = <void*>&ncoords[0, 0]
    coords_ffi.len = ncoords.shape[0]
    cdef InternalArray result = simplify_visvalingam_idx_ffi(coords_ffi, epsilon)
    cdef size_t* incoming_ptr = <size_t*>(result.data)
    cdef size_t[::1] view = <size_t[:result.len]>incoming_ptr
    if isinstance(coords, numpy.ndarray):
        outgoing = np.copy(view)
    else:
        outgoing = np.copy(view).tolist()
    try:
        return outgoing
    finally:
        drop_usize_array(result)

cpdef simplify_coords_vwp(coords, double epsilon):
    """
    Simplify a LineString using a topology-preserving variant of the
    Visvalingam-Whyatt algorithm.
    Input: a list of lat, lon coordinates, and an epsilon float
    Output: a simplified list of coordinates

    Example:
    simplify_coords([
        [5.0, 2.0], [3.0, 8.0], [6.0, 20.0], [7.0, 25.0], [10.0, 10.0]],
        30.0
    )
    Result: [[5.0, 2.0], [7.0, 25.0], [10.0, 10.0]]

    """
    if not len(coords):
        return coords
    cdef double[:,::1] ncoords = np.array(coords, dtype=np.float64)
    cdef ExternalArray coords_ffi
    coords_ffi.data = <void*>&ncoords[0, 0]
    coords_ffi.len = ncoords.shape[0]

    cdef InternalArray result = simplify_visvalingamp_ffi(coords_ffi, epsilon)
    cdef double* incoming_ptr = <double*>(result.data)
    cdef double[:, ::1] view = <double[:result.len,:2:1]>incoming_ptr
    if isinstance(coords, numpy.ndarray):
        outgoing = np.copy(view)
    else:
        outgoing = np.copy(view).tolist()
    try:
        return outgoing
    finally:
        drop_float_array(result)
