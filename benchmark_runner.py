#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Standalone benchmark runner
"""

import cProfile
import pstats
import profile
import numpy as np

print("Running Rust + Cython benchmarks")

# calibrate
pr = profile.Profile()
calibration = np.mean([pr.calibrate(100000) for x in xrange(5)])
# add the bias
profile.Profile.bias = calibration

cProfile.run(open('simplification/test/cprofile_rust_cython.py', 'rb'), 'simplification/test/output_stats_rust_cython')
rust_cython = pstats.Stats('simplification/test/output_stats_rust_cython')

cProfile.run(open('simplification/test/cprofile_rust_cython_complex.py', 'rb'), 'simplification/test/output_stats_rust_cython_complex')
rust_cython_c = pstats.Stats('simplification/test/output_stats_rust_cython_complex')

cProfile.run(open('simplification/test/cprofile_rust_cython_shapely.py', 'rb'), 'simplification/test/output_stats_rust_cython_shapely')
shapely = pstats.Stats('simplification/test/output_stats_rust_cython_shapely')

print("Rust Cython Benchmarks\n")
rust_cython.sort_stats('cumulative').print_stats(5)
rust_cython_c.sort_stats('cumulative').print_stats(5)
shapely.sort_stats('cumulative').print_stats(5)
