[![Build Status](https://github.com/urschrei/simplification/actions/workflows/wheels.yml/badge.svg)](https://github.com/urschrei/simplification/actions/workflows/wheels.yml) [![Coverage Status](https://coveralls.io/repos/github/urschrei/simplification/badge.svg?branch=master)](https://coveralls.io/github/urschrei/simplification?branch=master) [![Downloads](https://pepy.tech/badge/simplification)](https://pepy.tech/project/simplification) [![DOI](https://zenodo.org/badge/65199659.svg)](https://zenodo.org/badge/latestdoi/65199659) [![Anaconda-Server Badge](https://anaconda.org/conda-forge/simplification/badges/version.svg)](https://anaconda.org/conda-forge/simplification)

# Simplification
Simplify a LineString using the [Ramer–Douglas–Peucker](https://en.wikipedia.org/wiki/Ramer–Douglas–Peucker_algorithm) or [Visvalingam-Whyatt](https://bost.ocks.org/mike/simplify/) algorithms

![Line](https://cdn.rawgit.com/urschrei/rdp/6c84264fd9cdc0b8fdf974fc98e51fea4834ed05/rdp.svg)  

## Installation
`uv add simplification` OR  
`pip install simplification` OR  
`conda install conda-forge::simplification`

### Installing for local development
1. Ensure you have a copy of `librdp` from https://github.com/urschrei/rdp/releases, and it's in the `src/simplification` subdir
2. run `pip install -e .[test] --use-pep517`
3. run `pytest .`

### Supported Python Versions
Simplification supports all [_currently_ supported Python versions](https://devguide.python.org/versions/).

### Supported Platforms
- Linux (`manylinux`-compatible) x86_64 and aarch64
- macOS Darwin x86_64 and arm64
- Windows 64-bit

## Usage
```python
from simplification.cutil import (
    simplify_coords,
    simplify_coords_idx,
    simplify_coords_vw,
    simplify_coords_vw_idx,
    simplify_coords_vwp,
)

# Using Ramer–Douglas–Peucker
coords = [
    [0.0, 0.0],
    [5.0, 4.0],
    [11.0, 5.5],
    [17.3, 3.2],
    [27.8, 0.1]
]

# For RDP, Try an epsilon of 1.0 to start with. Other sensible values include 0.01, 0.001
simplified = simplify_coords(coords, 1.0)

# simplified is [[0.0, 0.0], [5.0, 4.0], [11.0, 5.5], [27.8, 0.1]]

# Using Visvalingam-Whyatt
# You can also pass numpy arrays, in which case you'll get numpy arrays back
import numpy as np
coords_vw = np.array([
    [5.0, 2.0],
    [3.0, 8.0],
    [6.0, 20.0],
    [7.0, 25.0],
    [10.0, 10.0]
])
simplified_vw = simplify_coords_vw(coords_vw, 30.0)

# simplified_vw is [[5.0, 2.0], [7.0, 25.0], [10.0, 10.0]]
```

Passing empty and/or 1-element lists will return them unaltered.

## But I only want the simplified **Indices**
`simplification` now has:

- `cutil.simplify_coords_idx`
- `cutil.simplify_coords_vw_idx`

The values returned by these functions are the **retained** indices. In order to use them as e.g. a [masked array](https://docs.scipy.org/doc/numpy/reference/maskedarray.generic.html#what-is-a-masked-array) in Numpy, something like the following will work:

    import numpy as np
    from simplification.cutil import simplify_coords_idx

    # assume an array of coordinates: orig
    simplified = simplify_coords_idx(orig, 1.0)
    # build new geometry using only retained coordinates
    orig_simplified = orig[simplified]


## But I need to ensure that the resulting geometries are valid
You can use the topology-preserving variant of `VW` for this: `simplify_coords_vwp`. It's slower, but has a far greater likelihood of producing a valid geometry.


## But I Want to Simplify Polylines
No problem; [Decode them to LineStrings](https://github.com/urschrei/pypolyline) first.

``` python
# pip install pypolyline before you do this
from pypolyline.cutil import decode_polyline
# an iterable of Google-encoded Polylines, so precision is 5. For OSRM &c., it's 6
decoded = (decode_polyline(line, 5) for line in polylines)
simplified = [simplify_coords(line, 1.0) for line in decoded]
```

## How it Works
FFI and a [Rust binary](https://github.com/urschrei/rdp)

## Is It Fast
I should think so.
### What does that mean
Using `numpy` arrays for input and output, the library can be reasonably expected to process around 2500 1000-point LineStrings per second on a Core i7 or equivalent, for a 98%+ reduction in size.  
A larger LineString, containing 200k+ points can be reduced to around 3k points (98.5%+) in around 50ms using RDP.

This is based on a test harness available [here](benchmark_runner.py).
#### Disclaimer
All benchmarks are subjective, and pathological input will greatly increase processing time. Error-checking is non-existent at this point.

## License
[Blue Oak Model Licence 1.0.0](LICENSE.md)

## Citing `Simplification`
If Simplification has been significant in your research, and you would like to acknowledge the project in your academic publication, we suggest citing it as follows (example in APA style, 7th edition):

> Hügel, S. (2021). Simplification (Version X.Y.Z) [Computer software]. https://doi.org/10.5281/zenodo.5774852

In Bibtex format:

    @software{Hugel_Simplification_2021,
    author = {Hügel, Stephan},
    doi = {10.5281/zenodo.5774852},
    license = {MIT},
    month = {12},
    title = {{Simplification}},
    url = {https://github.com/urschrei/simplification},
    version = {X.Y.Z},
    year = {2021}
    }
