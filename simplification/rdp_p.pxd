cdef extern from "header.h":
    struct Array:
        void* data
        size_t len

    cdef Array simplify_rdp_ffi(Array, double epsilon);
    cdef Array simplify_visvalingam_ffi(Array, double epsilon);
    cdef void drop_float_array(Array coords);
