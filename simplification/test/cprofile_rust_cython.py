# this tests numpy array simplification using VW

from simplification.cutil import simplify_coords_vw
import json
import numpy as np

if __name__ == "__main__":
    with open("simplification/test/coords.json", 'r') as f:
        coords = np.array(json.load(f))
    for x in xrange(2500):
        simplify_coords_vw(coords, 0.0000075)
