Simplification 
==============

|Line|

Simplify a LineString using the
`Ramer–Douglas–Peucker <https://en.wikipedia.org/wiki/Ramer–Douglas–Peucker_algorithm>`_ or `Visvalingam–Whyatt <https://bost.ocks.org/mike/simplify/>`_
algorithms


Installation
------------

``pip install simplification``

Please use a recent (>= 8.1.2) version of ``pip``

Supported Python Versions
~~~~~~~~~~~~~~~~~~~~~~~~~

-  Python 2.7
-  Python 3.4
-  Python 3.5
-  Python 3.6

Supported Platforms
~~~~~~~~~~~~~~~~~~~


-  Linux (``manylinux1``-compatible)
-  OS X
-  Windows 32-bit / 64-bit

Usage
-----

.. code-block:: python

    from simplification.cutil import simplify_coords, simplify_coordsvw

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
    coords_vw = [
        [5.0, 2.0],
        [3.0, 8.0],
        [6.0, 20.0],
        [7.0, 25.0],
        [10.0, 10.0]
    ]
    simplified_vw = simplify_coords_vw(coords, 30.0)

    # simplified_vw is [[5.0, 2.0], [7.0, 25.0], [10.0, 10.0]]


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
