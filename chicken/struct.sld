(define-library (bytestructures struct)
  (import
   (scheme base)
   (scheme case-lambda)
   (srfi 1)
   (bytestructures utils)
   (bytestructures base)
   (bytestructures bitfields))
  (cond-expand
   ((library (srfi 28))
    (import (srfi 28)))
   (chicken
    (import (format))))
  (include-library-declarations "r7/struct.exports.sld")
  (include "body/struct.scm"))
