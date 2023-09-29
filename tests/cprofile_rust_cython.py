# this tests numpy array simplification using VW

from simplification.cutil import simplify_coords_vw
import json
import numpy as np

with open("test/coords.json", "r") as f:
    coords = np.array(json.load(f))
for x in range(50):
    simplify_coords_vw(coords, 0.0000075)
