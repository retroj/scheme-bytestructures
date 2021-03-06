(define-library (bytestructures r7)
  (import
   (bytestructures r7 base)
   (bytestructures r7 vector)
   (bytestructures r7 struct)
   (bytestructures r7 union)
   (bytestructures r7 numeric))
  (include-library-declarations "r7/base.exports.sld")
  (include-library-declarations "r7/vector.exports.sld")
  (include-library-declarations "r7/struct.exports.sld")
  (include-library-declarations "r7/union.exports.sld")
  (include-library-declarations "r7/numeric.exports.sld"))
