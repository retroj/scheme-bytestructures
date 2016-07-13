(define-library (bytestructures utils)
  (import (scheme base))
  (export
   define-syntax-rule
   if-syntax-case
   define-syntax-case-stubs
   quasisyntax
   unsyntax
   unsyntax-splicing
   syntax->datum
   datum->syntax
   )
  (include "body/utils.scm"))
