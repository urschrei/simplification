[![Build Status](https://travis-ci.org/urschrei/simplification.svg?branch=master)](https://travis-ci.org/urschrei/simplification) [![Build status](https://ci.appveyor.com/api/projects/status/0n7d5iwb3uqhsos6/branch/master?svg=true)](https://ci.appveyor.com/project/urschrei/simplification/branch/master) [![Coverage Status](https://coveralls.io/repos/github/urschrei/simplification/badge.svg?branch=master)](https://coveralls.io/github/urschrei/simplification?branch=master)

# Simplification
Simplify a LineString using the [Ramer–Douglas–Peucker](https://en.wikipedia.org/wiki/Ramer–Douglas–Peucker_algorithm) or [Visvalingam-Whyatt](https://bost.ocks.org/mike/simplify/) algorithms

![Line](https://cdn.rawgit.com/urschrei/rdp/6c84264fd9cdc0b8fdf974fc98e51fea4834ed05/rdp.svg)  

## Installation
`pip install simplification`  
Please use a recent (>= 8.1.2) version of `pip`.

### Supported Python Versions
- Python 2.7
- Python 3.5
- Python 3.6

### Supported Platforms
- Linux (`manylinux1`-compatible)  
- OS X
- Windows 32-bit / 64-bit 

## Usage
```python
from simplification.cutil import simplify_coords, simplify_coords_vw

coords = [
            [0.0, 0.0], [5.0, 4.0],
            [11.0, 5.5], [17.3, 3.2],
            [27.8, 0.1]
        ]

# For RDP, Try an epsilon of 1.0 to start with. Other sensible values include 0.01, 0.001
simplified = simplify_coords(coords, 1.0)

# simplified is [[0.0, 0.0], [5.0, 4.0], [11.0, 5.5], [27.8, 0.1]]
```

Passing empty and/or 1-element lists will return them unaltered.
## How it Works
FFI and a [Rust binary](https://github.com/urschrei/rdp)

## Is It Fast
I should think so.

## License
[MIT](license.txt)
