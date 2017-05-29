
#ifndef cheddar_generated_header_h
#define cheddar_generated_header_h


#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdbool.h>



/// A C-compatible `struct` used for passing arrays across the FFI boundary
typedef struct Array {
	void const* data;
	size_t len;
} Array;

/// FFI wrapper for [`rdp`](fn.rdp.html)
///
/// Callers must pass two arguments:
///
/// - a [Struct](struct.Array.html) with two fields:
///     - `data`, a void pointer to an array of floating-point point coordinates: `[[1.0, 2.0], …]`
///     - `len`, the length of the array being passed. Its type must be `size_t`
/// - a double-precision `float` for the tolerance
///
/// Implementations calling this function **must** call [`drop_float_array`](fn.drop_float_array.html)
/// with the returned `Array` pointer, in order to free the memory it allocates.
///
/// # Safety
///
/// This function is unsafe because it accesses a raw pointer which could contain arbitrary data
Array simplify_rdp_ffi(Array coords, double precision);

/// FFI wrapper for [`visvalingam`](fn.visvalingam.html)
///
/// Callers must pass two arguments:
///
/// - a [Struct](struct.Array.html) with two fields:
///     - `data`, a void pointer to an array of floating-point point coordinates: `[[1.0, 2.0], …]`
///     - `len`, the length of the array being passed. Its type must be `size_t`
/// - a double-precision `float` for the epsilon
///
/// Implementations calling this function **must** call [`drop_float_array`](fn.drop_float_array.html)
/// with the returned `Array` pointer, in order to free the memory it allocates.
///
/// # Safety
///
/// This function is unsafe because it accesses a raw pointer which could contain arbitrary data
Array simplify_visvalingam_ffi(Array coords, double precision);

/// Free Array memory which Rust has allocated across the FFI boundary by [`simplify_rdp_ffi`](fn.simplify_rdp_ffi.html)
///
/// # Safety
///
/// This function is unsafe because it accesses a raw pointer which could contain arbitrary data
void drop_float_array(Array arr);



#ifdef __cplusplus
}
#endif


#endif
