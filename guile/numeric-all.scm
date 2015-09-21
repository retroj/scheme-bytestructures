(define-module (bytestructures guile numeric-all))
(import
 (bytestructures bytevectors)
 (bytestructures guile utils)
 (bytestructures guile base)
 (bytestructures guile explicit-endianness))
(include-from-path "bytestructures/body/numeric.scm")
(export
 int8 uint8 int16 uint16 int32 uint32 int64 uint64
 int16le uint16le int32le uint32le int64le uint64le
 int16be uint16be int32be uint32be int64be uint64be
 float32 double64 float32le double64le float32be double64be
 signed-integer-native-descriptors
 signed-integer-le-descriptors
 signed-integer-be-descriptors
 signed-integer-descriptors
 unsigned-integer-native-descriptors
 unsigned-integer-le-descriptors
 unsigned-integer-be-descriptors
 unsigned-integer-descriptors
 float-native-descriptors
 float-le-descriptors
 float-be-descriptors
 integer-descriptors
 float-descriptors
 numeric-descriptors
 )