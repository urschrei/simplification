# this tests numpy array simplification using RDP
# 216804 --> 3061 points (98.5% reduction)
# 50ms per VW operation on MBA Core i7


# Note that for the equivalent VW output  we should reduce tolerance by an order of magnitude, then divide by 2
# e.g. 0.01 -> 0.0005

from simplification.cutil import simplify_coords
import json
import numpy as np

with open("test/coords_complex.json", "r") as f:
    coords = np.array(json.load(f))
for x in range(50):
    simplify_coords(coords, 0.01)
