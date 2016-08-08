# -*- coding: utf-8 -*-

import unittest
from simplification.util import simplify_coords
from simplification.cutil import simplify_coords as csimplify_coords

class PolylineTests(unittest.TestCase):
    """ Tests for simplification """

    def setUp(self):
        """ make these available to all tests """
        self.coords = [
            [0.0, 0.0], [5.0, 4.0],
            [11.0, 5.5], [17.3, 3.2],
            [27.8, 0.1]
        ]

        self.result = [
            [0.0, 0.0], [5.0, 4.0],
            [11.0, 5.5], [27.8, 0.1]
        ]

        self.single = [[5.0, 4.0]]

        self.empty = []

    def testSimplify(self):
        """ Test that a LineString can be simplified (Ctypes) """
        expected = self.result
        result = simplify_coords(self.coords, 1.0)
        for _ in range(100):
            self.assertEqual(result, expected)

    def testCSimplify(self):
        """ Test that a LineString can be simplified (Cython) """
        expected = self.result
        result = csimplify_coords(self.coords, 1.0)
        for _ in range(100):
            self.assertEqual(result, expected)

    def testCSingle(self):
        """ Test that a one-element LineString is returned unaltered (Cython) """
        result = csimplify_coords(self.single, 1.0)
        self.assertEqual(result, self.single)

    def testCEmpty(self):
        """ Test that an empty LineString is returned unaltered (Cython) """
        result = csimplify_coords(self.empty, 1.0)
        self.assertEqual(result, [])
