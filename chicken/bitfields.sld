(define-library (bytestructures bitfields)
  (import
   (scheme base)
   (srfi 60)
   (bytestructures utils)
   (bytestructures base)
   (bytestructures numeric-metadata))
  (include-library-declarations "r7/bitfields.exports.sld")
  (include "body/bitfields.scm"))
