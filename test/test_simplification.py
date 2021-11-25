# -*- coding: utf-8 -*-

import unittest
import numpy as np
import numpy
from simplification.util import simplify_coords, simplify_coords_vw
from simplification.cutil import simplify_coords as csimplify_coords
from simplification.cutil import simplify_coords_idx as csimplify_coords_idx
from simplification.cutil import simplify_coords_vw as csimplify_coords_vw
from simplification.cutil import simplify_coords_vw_idx as csimplify_coords_vw_idx
from simplification.cutil import simplify_coords_vwp as csimplify_coords_vwp


class PolylineTests(unittest.TestCase):
    """ Tests for simplification """

    def setUp(self):
        """ make these available to all tests """
        self.coords = [[0.0, 0.0], [5.0, 4.0], [11.0, 5.5], [17.3, 3.2], [27.8, 0.1]]

        self.coordsvw = [[5.0, 2.0], [3.0, 8.0], [6.0, 20.0], [7.0, 25.0], [10.0, 10.0]]

        self.result = [[0.0, 0.0], [5.0, 4.0], [11.0, 5.5], [27.8, 0.1]]

        self.result_rdp_idx = [0, 1, 2, 4]

        self.resultvw = [[5.0, 2.0], [7.0, 25.0], [10.0, 10.0]]

        self.resultvw_idx = [0, 3, 4]

        self.single = [[5.0, 4.0]]

        self.empty = []

    def test_contiguous(self):
        """ Test that non-contiguous arrays are transformed into contiguous arrays """
        x = np.array([1, 2, 3, 4, 5])
        y = np.array([0, 1, 1, 1, 0])
        coords = np.transpose(np.stack((x, y)))

        simplified = csimplify_coords(coords, 1.0)

    def testSimplify_rdp_numpy(self):
        """ Test that numpy arrays can be consumed and returned """
        npcoords = np.array(self.coords)
        result = csimplify_coords(npcoords, 1.0)
        self.assertEqual(type(result), numpy.ndarray)

    def testSimplify_rdp(self):
        """ Test that a LineString can be simplified using RDP (Ctypes) """
        expected = self.result
        result = simplify_coords(self.coords, 1.0)
        for _ in range(100):
            self.assertEqual(result, expected)

    def testSimplify_vw(self):
        """ Test that a LineString can be simplified using VW (Ctypes) """
        expected = self.resultvw
        result = simplify_coords_vw(self.coordsvw, 30.0)
        for _ in range(100):
            self.assertEqual(result, expected)

    def testCSimplify_rdp(self):
        """ Test that a LineString can be simplified using RDP (Cython) """
        expected = self.result
        result = csimplify_coords(self.coords, 1.0)
        for _ in range(100):
            self.assertEqual(result, expected)

    def testCSimplify_rdp_idx(self):
        """ Test that a LineString can be simplified using RDP (Cython) """
        expected = self.result_rdp_idx
        result = csimplify_coords_idx(self.coords, 1.0)
        for _ in range(100):
            self.assertEqual(result, expected)

    def testCSimplify_vw(self):
        """ Test that a LineString can be simplified using VW (Cython) """
        expected = self.resultvw
        result = csimplify_coords_vw(self.coordsvw, 30.0)
        for _ in range(100):
            self.assertEqual(result, expected)

    def testCSimplify_vw_idx(self):
        """ Test that a LineString can be simplified using VW (Cython) """
        expected = self.resultvw_idx
        result = csimplify_coords_vw_idx(self.coordsvw, 30.0)
        for _ in range(100):
            self.assertEqual(result, expected)

    def testCSimplify_vw_preserve(self):
        """ Test that a LineString can be simplified using topology-preserving VW (Cython) """
        expected = self.resultvw
        result = csimplify_coords_vwp(self.coordsvw, 30.0)
        for _ in range(100):
            self.assertEqual(result, expected)

    # def testCSingle_rdp(self):
    #     """ Test that a one-element LineString is returned unaltered from RDP (Cython) """
    #     result = csimplify_coords(self.single, 1.0)
    #     self.assertEqual(result, self.single)

    def testCSingle_vw(self):
        """ Test that a one-element LineString is returned unaltered from VW (Cython) """
        result = csimplify_coords_vw(self.single, 1.0)
        self.assertEqual(result, self.single)

    def testCEmpty_rdp(self):
        """ Test that an empty LineString is returned unaltered from RDP (Cython) """
        result = csimplify_coords(self.empty, 1.0)
        self.assertEqual(result, [])

    # def testCEmpty_vw(self):
    #     """ Test that an empty LineString is returned unaltered from VW (Cython) """
    #     result = csimplify_coords_vw(self.empty, 1.0)
    #     self.assertEqual(result, [])
