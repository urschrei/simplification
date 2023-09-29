cdef extern from "header.h":
    struct ExternalArray:
        void* data
        size_t len

cdef extern from "header.h":
    struct InternalArray:
        void* data
        size_t len

    cdef InternalArray simplify_rdp_ffi(ExternalArray, double epsilon);
    cdef InternalArray simplify_rdp_idx_ffi(ExternalArray, double epsilon);
    cdef InternalArray simplify_visvalingam_ffi(ExternalArray, double epsilon);
    cdef InternalArray simplify_visvalingam_idx_ffi(ExternalArray, double epsilon);
    cdef InternalArray simplify_visvalingamp_ffi(ExternalArray, double epsilon);
    cdef void drop_float_array(InternalArray coords);
    cdef void drop_usize_array(InternalArray coords);
