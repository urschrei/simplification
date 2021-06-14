# this tests numpy array simplification using VW
# 216804 --> 3061 points (98.5% reduction)
# 300ms per RDP operation on MBA Core i7

import json
import numpy as np
from shapely.geometry import LineString

with open("simplification/test/coords_complex.json", "r") as f:
    coords = np.array(json.load(f))
    ls = LineString(coords)
for x in range(50):
    ls.simplify(14.0, preserve_topology=False)
