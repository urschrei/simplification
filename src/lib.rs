//! Python bindings for the line simplification algorithms in the [`geo`](https://crates.io/crates/geo) crate.

use geo::{
    Coord, LineString, Simplify, SimplifyIdx, SimplifyVw, SimplifyVwIdx, SimplifyVwPreserve,
};
use numpy::ndarray::Array2;
use numpy::{IntoPyArray, PyUntypedArray};
use pyo3::buffer::PyBuffer;
use pyo3::exceptions::PyValueError;
use pyo3::prelude::*;

/// Copy `coords` into a `LineString`.
///
/// Any object exposing a float64 buffer (e.g. a NumPy array, contiguous or not) is read directly,
/// and must have shape `(N, 2)`. NumPy arrays of other dtypes are converted to float64 first.
/// Anything else must be a sequence of `(x, y)` pairs.
fn extract_coords(coords: &Bound<'_, PyAny>) -> PyResult<LineString<f64>> {
    let buf = match PyBuffer::<f64>::get(coords) {
        Ok(buf) => Some(buf),
        Err(_) if coords.is_instance_of::<PyUntypedArray>() => Some(PyBuffer::get(
            &coords.call_method1("astype", ("float64",))?,
        )?),
        Err(_) => None,
    };
    if let Some(buf) = buf {
        if !matches!(buf.shape(), [_, 2]) {
            return Err(PyValueError::new_err(format!(
                "coordinates must have shape (N, 2), got {:?}",
                buf.shape()
            )));
        }
        // Read C-contiguous buffers in place, and copy anything else into C order first
        let py = coords.py();
        return Ok(match buf.as_slice(py) {
            Some(cells) => cells
                .chunks_exact(2)
                .map(|c| Coord {
                    x: c[0].get(),
                    y: c[1].get(),
                })
                .collect(),
            None => buf
                .to_vec(py)?
                .chunks_exact(2)
                .map(|c| Coord { x: c[0], y: c[1] })
                .collect(),
        });
    }
    let pairs: Vec<[f64; 2]> = coords.extract().map_err(|e| {
        let err = PyValueError::new_err("coordinates must be a sequence of (x, y) number pairs");
        err.set_cause(coords.py(), Some(e));
        err
    })?;
    Ok(pairs.into_iter().map(|[x, y]| Coord { x, y }).collect())
}

/// A simplified LineString, or the indices of its retained coordinates
enum Simplified {
    Coords(LineString<f64>),
    Indices(Vec<usize>),
}

/// Simplify `coords` using `algorithm`, without holding the GIL.
///
/// Empty input is returned unaltered. NumPy array input produces NumPy array output, and
/// anything else produces lists.
fn simplify<'py>(
    coords: &Bound<'py, PyAny>,
    epsilon: f64,
    algorithm: fn(&LineString<f64>, f64) -> Simplified,
) -> PyResult<Bound<'py, PyAny>> {
    if coords.len()? == 0 {
        return Ok(coords.clone());
    }
    let py = coords.py();
    let ls = extract_coords(coords)?;
    let simplified = py.detach(|| algorithm(&ls, epsilon));
    let as_array = coords.is_instance_of::<PyUntypedArray>();
    match simplified {
        Simplified::Coords(ls) if as_array => {
            let flat: Vec<f64> = ls.0.iter().flat_map(|c| [c.x, c.y]).collect();
            let arr = Array2::from_shape_vec((ls.0.len(), 2), flat)
                .expect("a LineString flattens to (N, 2)");
            Ok(arr.into_pyarray(py).into_any())
        }
        Simplified::Coords(ls) => {
            let pairs: Vec<[f64; 2]> = ls.0.iter().map(|c| [c.x, c.y]).collect();
            pairs.into_pyobject(py)
        }
        Simplified::Indices(idx) if as_array => Ok(idx.into_pyarray(py).into_any()),
        Simplified::Indices(idx) => idx.into_pyobject(py),
    }
}

/// Simplify a LineString using the Ramer-Douglas-Peucker algorithm.
/// Input: a list of lat, lon coordinates, and an epsilon float (Try 1.0 to begin with, reducing by orders of magnitude)
/// Output: a simplified list of coordinates
///
/// Example: simplify_coords([
///     [0.0, 0.0], [5.0, 4.0], [11.0, 5.5], [17.3, 3.2], [27.8, 0.1]],
///     1.0)
/// Result: [[0.0, 0.0], [5.0, 4.0], [11.0, 5.5], [27.8, 0.1]]
#[pyfunction]
fn simplify_coords<'py>(coords: &Bound<'py, PyAny>, epsilon: f64) -> PyResult<Bound<'py, PyAny>> {
    simplify(coords, epsilon, |ls, e| Simplified::Coords(ls.simplify(e)))
}

/// Simplify a LineString using the Ramer-Douglas-Peucker algorithm.
/// Input: a list of lat, lon coordinates, and an epsilon float (Try 1.0 to begin with, reducing by orders of magnitude)
/// Output: a simplified list of coordinate indices
///
/// Example: simplify_coords_idx([
///     [0.0, 0.0], [5.0, 4.0], [11.0, 5.5], [17.3, 3.2], [27.8, 0.1]],
///     1.0)
/// Result: [0, 1, 2, 4]
#[pyfunction]
fn simplify_coords_idx<'py>(
    coords: &Bound<'py, PyAny>,
    epsilon: f64,
) -> PyResult<Bound<'py, PyAny>> {
    simplify(coords, epsilon, |ls, e| {
        Simplified::Indices(ls.simplify_idx(e))
    })
}

/// Simplify a LineString using the Visvalingam-Whyatt algorithm.
/// Input: a list of lat, lon coordinates, and an epsilon float
/// Output: a simplified list of coordinates
///
/// Example: simplify_coords_vw([
///     [5.0, 2.0], [3.0, 8.0], [6.0, 20.0], [7.0, 25.0], [10.0, 10.0]],
///     30.0)
/// Result: [[5.0, 2.0], [7.0, 25.0], [10.0, 10.0]]
#[pyfunction]
fn simplify_coords_vw<'py>(
    coords: &Bound<'py, PyAny>,
    epsilon: f64,
) -> PyResult<Bound<'py, PyAny>> {
    simplify(coords, epsilon, |ls, e| {
        Simplified::Coords(ls.simplify_vw(e))
    })
}

/// Simplify a LineString using the Visvalingam-Whyatt algorithm.
/// Input: a list of lat, lon coordinates, and an epsilon float
/// Output: a simplified list of coordinate indices
///
/// Example: simplify_coords_vw_idx([
///     [5.0, 2.0], [3.0, 8.0], [6.0, 20.0], [7.0, 25.0], [10.0, 10.0]],
///     30.0)
/// Result: [0, 3, 4]
#[pyfunction]
fn simplify_coords_vw_idx<'py>(
    coords: &Bound<'py, PyAny>,
    epsilon: f64,
) -> PyResult<Bound<'py, PyAny>> {
    simplify(coords, epsilon, |ls, e| {
        Simplified::Indices(ls.simplify_vw_idx(e))
    })
}

/// Simplify a LineString using a topology-preserving variant of the
/// Visvalingam-Whyatt algorithm.
/// Input: a list of lat, lon coordinates, and an epsilon float
/// Output: a simplified list of coordinates
///
/// Example: simplify_coords_vwp([
///     [5.0, 2.0], [3.0, 8.0], [6.0, 20.0], [7.0, 25.0], [10.0, 10.0]],
///     30.0)
/// Result: [[5.0, 2.0], [7.0, 25.0], [10.0, 10.0]]
#[pyfunction]
fn simplify_coords_vwp<'py>(
    coords: &Bound<'py, PyAny>,
    epsilon: f64,
) -> PyResult<Bound<'py, PyAny>> {
    simplify(coords, epsilon, |ls, e| {
        Simplified::Coords(ls.simplify_vw_preserve(e))
    })
}

#[pymodule(gil_used = false)]
mod cutil {
    #[pymodule_export]
    use super::{
        simplify_coords, simplify_coords_idx, simplify_coords_vw, simplify_coords_vw_idx,
        simplify_coords_vwp,
    };
}
