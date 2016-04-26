(define-library (bytestructures r7 struct)
  (import
   (scheme base)
   (scheme case-lambda)
   (srfi 1)
   (bytestructures r7 utils)
   (bytestructures r7 base)
   (bytestructures r7 bitfields))
  (cond-expand
   ((library (srfi 28))
    (import (srfi 28)))
   (chicken
    (import (format))))
  (include-library-declarations "struct.exports.sld")
  (include "body/struct.scm"))
