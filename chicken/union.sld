(define-library (bytestructures union)
  (import
   (scheme base)
   (bytestructures utils)
   (bytestructures base))
  (include-library-declarations "r7/union.exports.sld")
  (include "body/union.scm"))
