(define-library (bytestructures r7 struct)
  (import
   (scheme base)
   (bytestructures r7 base)
   (bytestructures r7 utils))
  (include-library-declarations "struct.exports.scm")
  (include "../body/struct.scm"))
