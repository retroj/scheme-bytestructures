(define-library (bytestructures base)
  (import
   (scheme base)
   (scheme case-lambda)
   (bytestructures utils))
  (include-library-declarations "r7/base.exports.sld")
  (include "body/base.scm"))
