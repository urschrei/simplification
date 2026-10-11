# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-10-11

### Changed

- **Breaking:** coordinates must have shape `(N, 2)`, and anything else raises `ValueError`. Previously, an `(N, 3)` input was silently misread as a different set of `(x, y)` pairs, producing an incorrect result.
- **Breaking:** coordinates must be numbers. Numeric strings such as `"1.0"` are no longer converted, and raise `ValueError`.
- The extension is now built from the Rust [geo](https://crates.io/crates/geo) crate using [PyO3](https://pyo3.rs) and [maturin](https://www.maturin.rs), replacing the Cython wrapper around the prebuilt [rdp](https://github.com/urschrei/rdp) library. The wheel no longer bundles a separate shared library. Results are unchanged.
- The GIL is released while simplifying.
- Simplification is faster for most inputs, particularly small ones and lists of coordinates.

### Added

- The source distribution can now be built and installed on platforms without a prebuilt wheel, given a Rust toolchain.
- The extension module declares support for free-threaded CPython builds.

### Removed

- **Breaking:** the ctypes interface in `simplification.util`. Use `simplification.cutil` instead, which has the same functions, but returns NumPy arrays for NumPy array input rather than always returning lists.
- **Breaking:** support for Python 3.10.

### Fixed

- Fortran-ordered NumPy arrays are accepted by every function. Previously, only `simplify_coords` accepted them.
- The `simplify_coords_idx` and `simplify_coords_vw_idx` docstrings show the correct function and index results.

## [1.0.0] and earlier

See the [commit history](https://github.com/urschrei/simplification/commits/v1.0.0).

[2.0.0]: https://github.com/urschrei/simplification/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/urschrei/simplification/releases/tag/v1.0.0
