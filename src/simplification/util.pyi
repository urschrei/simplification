from collections.abc import Sequence

import numpy as np
from numpy.typing import NDArray

_Coords = Sequence[Sequence[float]] | NDArray[np.float64]

def simplify_coords(coords: _Coords, epsilon: float) -> list[list[float]]: ...
def simplify_coords_vw(coords: _Coords, epsilon: float) -> list[list[float]]: ...
def simplify_coords_vwp(coords: _Coords, epsilon: float) -> list[list[float]]: ...
