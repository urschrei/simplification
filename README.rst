|Line|
# Simplification Simplify a LineString using the
`Ramer–Douglas–Peucker <https://en.wikipedia.org/wiki/Ramer–Douglas–Peucker_algorithm>`_
algorithm

Installation
------------

``pip install simplification``
Please use a recent (>= 8.1.2) version of ``pip``.

Supported Python Versions
~~~~~~~~~~~~~~~~~~~~~~~~~


-  Python 2.7
-  Python 3.5

Supported Platforms
~~~~~~~~~~~~~~~~~~~


-  Linux (``manylinux1``-compatible)
-  OS X
-  Windows 32-bit / 64-bit

Usage
-----

.. code-block:: python

    from simplification.cutil import simplify_coords

    coords = [ [0.0, 0.0], [5.0, 4.0], [11.0, 5.5], [17.3, 3.2], [27.8,
    0.1] ]

    # Try an epsilon of 1.0 to start with. Other sensible values include 0.01, 0.001
    simplified = simplify\_coords(coords, 1.0)

    # simplified is [[0.0, 0.0], [5.0, 4.0], [11.0, 5.5], [27.8, 0.1]]


How it Works
------------

FFI and a `Rust binary <https://github.com/urschrei/rdp>`_

Is It Fast
----------

I should think so.

License
-------

`MIT <license.txt>`_

.. |Line| image:: https://cdn.rawgit.com/urschrei/rdp/6c84264fd9cdc0b8fdf974fc98e51fea4834ed05/rdp.svg