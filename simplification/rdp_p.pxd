cdef extern from "header.h":
    struct _FFIArray:
        void* data
        size_t len

    cdef _FFIArray simplify_linestring_ffi(_FFIArray, double epsilon);
    cdef void drop_float_array(_FFIArray coords);
