"""
util.py

Created by Stephan Hügel on 2016-08-3

This file is part of simplification.

These functions always return lists, even for NumPy array input. They wrap the
functions in `simplification.cutil`, which return NumPy arrays for NumPy array input.
"""

from simplification import cutil

__author__ = "Stephan Hügel"


def _as_list(result):
    return result.tolist() if hasattr(result, "tolist") else result


def simplify_coords(coords, epsilon):
    """
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
    return _as_list(cutil.simplify_coords(coords, epsilon))


def simplify_coords_vw(coords, epsilon):
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
    return _as_list(cutil.simplify_coords_vw(coords, epsilon))


def simplify_coords_vwp(coords, epsilon):
    """
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
    return _as_list(cutil.simplify_coords_vwp(coords, epsilon))
