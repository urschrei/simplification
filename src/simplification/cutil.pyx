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

# ---------------------------------------------------------------------------
# Typed-memoryview / FFI pattern used throughout this module
# ---------------------------------------------------------------------------
#
# Every public function follows the same four steps:
#
#   1. Coerce the input into a C-contiguous float64 buffer wrapped in a typed
#      memoryview, ``double[:, ::1]``. The ``::1`` marks the last axis as
#      contiguous (stride 1), i.e. C / row-major layout.
#   2. Hand the flat buffer to Rust as an ``ExternalArray`` (a ``void*`` plus a
#      length). ``&ncoords[0, 0]`` is the address of the first element, and
#      the length passed is ``ncoords.shape[0]``, the row count.
#   3. Rust returns an ``InternalArray`` (again a ``void*`` plus a length). A
#      memoryview cast reattaches a shape to that raw pointer, then ``np.copy``
#      moves the data into Python-owned storage.
#   4. Free the Rust-owned buffer (``drop_float_array`` / ``drop_usize_array``)
#      in a ``finally`` block, once the copy is safely ours.
#
# The width of a coordinate (how many doubles per point) is NOT carried by
# ExternalArray / InternalArray: both store only ``data`` and ``len``, and
# ``len`` is the number of rows, never the number of doubles. The width is an
# implicit contract held in two places that must agree:
#
#   * the Rust crate (a sibling repo), which reads and writes ``[f64; 2]``; and
#   * the output cast ``<double[:result.len, :2:1]>`` below, where the ``2`` is
#     the width and the trailing ``:1`` again marks the contiguous axis.
#
# To return triples ``(x, y, z)`` or quads ``(x, y, z, m)`` you would:
#
#   * change the Rust side to read and write ``[f64; 3]`` / ``[f64; 4]``;
#   * change every output cast from ``:2:1`` to ``:3:1`` / ``:4:1``; and
#   * optionally guard the input with ``assert ncoords.shape[1] == k``.
#
# The length would not change: it stays the row count, and Rust multiplies by
# the width internally. Note that the input side is not width-checked here, so
# passing an N x 3 array to the current width-2 code would be misread rather
# than rejected.
# ---------------------------------------------------------------------------

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
    # np.ascontiguousarray yields a C-contiguous float64 buffer in a single
    # call, copying only when the input is not already contiguous float64.
    # That is exactly what a double[:, ::1] memoryview requires: 2-D, last axis
    # contiguous (C / row-major). All five entry points coerce the same way.
    cdef double[:,::1] ncoords = np.ascontiguousarray(coords, dtype=np.float64)
    cdef ExternalArray coords_ffi
    # &ncoords[0, 0] is the start of the flat buffer; len is the row count, not
    # the number of doubles. ncoords must stay alive until the FFI call
    # returns, because coords_ffi.data points into it.
    coords_ffi.data = <void*>&ncoords[0, 0]
    coords_ffi.len = ncoords.shape[0]
    cdef InternalArray result = simplify_rdp_ffi(coords_ffi, epsilon)
    # Rust hands back a raw pointer with no shape. Reattach one:
    # [:result.len, :2:1] is result.len rows by 2 columns (x, y), last axis
    # contiguous. Change the 2 to 3 / 4 for triples / quads (see module header).
    cdef double* incoming_ptr = <double*>(result.data)
    cdef double[:, ::1] view = <double[:result.len,:2:1]>incoming_ptr
    # np.copy moves the data into Python-owned memory so the Rust buffer can be
    # freed below. Lists round-trip via .tolist().
    if isinstance(coords, numpy.ndarray):
        outgoing = np.copy(view)
    else:
        outgoing = np.copy(view).tolist()
    try:
        return outgoing
    finally:
        # Free the Rust-owned buffer now that outgoing holds an independent copy.
        drop_float_array(result)

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
    if not len(coords):
        return coords
    # Input handling mirrors simplify_coords (see that function and the module
    # header for the annotated version).
    cdef double[:,::1] ncoords = np.ascontiguousarray(coords, dtype=np.float64)
    cdef ExternalArray coords_ffi
    coords_ffi.data = <void*>&ncoords[0, 0]
    coords_ffi.len = ncoords.shape[0]
    cdef InternalArray result = simplify_rdp_idx_ffi(coords_ffi, epsilon)
    # The *_idx variants return a flat list of indices, not coordinate pairs,
    # so the output is 1-D: size_t[::1] has a single contiguous axis and no
    # width to specify. Freed with drop_usize_array (size_t, not double).
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
    cdef double[:,::1] ncoords = np.ascontiguousarray(coords, dtype=np.float64)
    cdef ExternalArray coords_ffi
    coords_ffi.data = <void*>&ncoords[0, 0]
    coords_ffi.len = ncoords.shape[0]
    cdef InternalArray result = simplify_visvalingam_ffi(coords_ffi, epsilon)
    # Coordinate (width-2) output; see simplify_coords and the module header
    # for the annotated version of this pattern.
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

    Example: simplify_coords_vw_idx([
        [5.0, 2.0], [3.0, 8.0], [6.0, 20.0], [7.0, 25.0], [10.0, 10.0]],
        30.0)
    Result: [0, 3, 4]

    """
    if not len(coords):
        return coords
    cdef double[:,::1] ncoords = np.ascontiguousarray(coords, dtype=np.float64)
    cdef ExternalArray coords_ffi
    coords_ffi.data = <void*>&ncoords[0, 0]
    coords_ffi.len = ncoords.shape[0]
    cdef InternalArray result = simplify_visvalingam_idx_ffi(coords_ffi, epsilon)
    # Index (1-D) output; see simplify_coords_idx for the annotated version.
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
    cdef double[:,::1] ncoords = np.ascontiguousarray(coords, dtype=np.float64)
    cdef ExternalArray coords_ffi
    coords_ffi.data = <void*>&ncoords[0, 0]
    coords_ffi.len = ncoords.shape[0]

    cdef InternalArray result = simplify_visvalingamp_ffi(coords_ffi, epsilon)
    # Coordinate (width-2) output; see simplify_coords and the module header
    # for the annotated version of this pattern.
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
