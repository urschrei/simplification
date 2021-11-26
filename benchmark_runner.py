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
calibration = np.mean([pr.calibrate(100000) for x in range(5)])
# add the bias
profile.Profile.bias = calibration

with open("test/cprofile_rust_cython.py", "rb") as f1:
    c1 = f1.read()

with open("test/cprofile_rust_cython_complex.py", "rb") as f2:
    c2 = f2.read()

with open("test/cprofile_rust_cython_shapely.py", "rb") as f3:
    c3 = f3.read()

cProfile.run(c1, "test/output_stats_rust_cython")
rust_cython = pstats.Stats("test/output_stats_rust_cython")

cProfile.run(c2, "test/output_stats_rust_cython_complex")
rust_cython_c = pstats.Stats("test/output_stats_rust_cython_complex")

cProfile.run(c3, "test/output_stats_rust_cython_shapely")
shapely = pstats.Stats("test/output_stats_rust_cython_shapely")

print("Rust Cython Benchmarks\n")
rust_cython.sort_stats("cumulative").print_stats(5)
rust_cython_c.sort_stats("cumulative").print_stats(5)
shapely.sort_stats("cumulative").print_stats(20)
