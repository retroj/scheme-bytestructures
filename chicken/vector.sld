(define-library (bytestructures vector)
  (import
   (scheme base)
   (bytestructures utils)
   (bytestructures base))
  (include-library-declarations "r7/vector.exports.sld")
  (include "body/vector.scm"))
