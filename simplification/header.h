#ifndef HEADER_H
#define HEADER_H

typedef struct _FFIArray {
    void* data;
    size_t len;
} _FFIArray;

_FFIArray simplify_linestring_ffi(_FFIArray coords, double epsilon);

void drop_float_array(_FFIArray arr);

#endif
