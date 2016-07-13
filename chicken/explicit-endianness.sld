(define-library (bytestructures explicit-endianness)
  (import
   (scheme base)
   (bytestructures utils)
   (bytestructures bytevectors))
  (include-library-declarations "r7/explicit-endianness.exports.sld")
  (include "body/explicit-endianness.scm"))
