;;; run-tests.body.scm --- Bytestructures test suite.

;; Copyright © 2015 Taylan Ulrich Bayırlı/Kammer <taylanbayirli@gmail.com>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; A relatively simple SRFI-64 test suite.


;;; Code:

(define-syntax-rule (test-= name expected expr)
  (test-approximate name expected expr 0))

(define-syntax-rule (maybe-skip-syntax . <body>)
  (if-syntax-case
   (begin . <body>)
   (begin)))

(test-begin "bytestructures")

(test-group "numeric"
  (define-syntax test-numeric-descriptors
    (syntax-rules ()
      ((_ <descriptor-id> ...)
       (let ()
         (define (destructure-numeric-descriptor-entry descriptor-entry proc)
           (define descriptor (list-ref descriptor-entry 0))
           (define name (list-ref descriptor-entry 1))
           (define getter (list-ref descriptor-entry 2))
           (define setter (list-ref descriptor-entry 3))
           (define size (bytestructure-descriptor-size descriptor))
           (define float? (assq descriptor float-descriptors))
           (define signed? (or float? (assq descriptor signed-integer-descriptors)))
           (proc descriptor name getter setter size float? signed?))
         (define (get-min/max float? signed? size)
           (cond
            (float?  (inexact (expt 2 (case size ((4) 24) ((8) 53)))))
            (signed? (- (expt 256 (- size 1))))
            (else    (- (expt 256 size) 1))))
         (destructure-numeric-descriptor-entry
          (assq <descriptor-id> numeric-descriptors)
          (lambda (descriptor name getter setter size float? signed?)
            (test-group (symbol->string name)
              (let ((test-value-1 (if float? 1.0 1))
                    (test-value-2 (if float? 2.0 1)))
                (test-group "procedural"
                  (define min/max (get-min/max float? signed? size))
                  (define bs (bytestructure descriptor))
                  (test-eqv "size" size (bytevector-length
                                         (bytestructure-bytevector bs)))
                  (test-= "ref" test-value-1
                    (begin
                      (setter (bytestructure-bytevector bs) 0 test-value-1)
                      (bytestructure-ref bs)))
                  (test-= "set" test-value-2
                    (begin
                      (bytestructure-set! bs test-value-2)
                      (getter (bytestructure-bytevector bs) 0)))
                  (test-= "min/max" min/max
                    (begin
                      (bytestructure-set! bs min/max)
                      (bytestructure-ref bs))))
                (maybe-skip-syntax
                 (test-group "syntactic"
                   (define min/max (get-min/max float? signed? size))
                   ;; Must insert the top-level reference <descriptor-id> here.
                   (define-bytestructure-accessors <descriptor-id>
                     bs-unwrapper bs-getter bs-setter)
                   (define bv (make-bytevector size))
                   (test-= "ref" test-value-1
                     (begin
                       (setter bv 0 test-value-1)
                       (bs-getter bv)))
                   (test-= "set" test-value-2
                     (begin
                       (bs-setter bv test-value-2)
                       (getter bv 0)))
                   (test-= "min/max" min/max
                     (begin
                       (bs-setter bv min/max)
                       (bs-getter bv)))))))))
         ...))))
  (test-numeric-descriptors
   float32 float32le float32be
   float64 float64le float64be
   int8 int16 int32 int64
   int16le int32le int64le
   int16be int32be int64be
   uint8 uint16 uint32 uint64
   uint16le uint32le uint64le
   uint16be uint32be uint64be))

(test-group "vector"
  (test-assert "create" (bs:vector 3 uint16))
  (test-group "procedural"
    (define bs (bytestructure (bs:vector 3 uint16)))
    (bytevector-u16-native-set! (bytestructure-bytevector bs) 2 321)
    (test-eqv "ref" 321 (bytestructure-ref bs 1))
    (test-eqv "set" 456 (begin (bytestructure-set! bs 1 456)
                               (bytestructure-ref bs 1)))
    (test-eqv "init" 321
      (let ((bs (bytestructure (bs:vector 3 uint16) #(321 123 321))))
        (bytestructure-ref bs 2))))
  (maybe-skip-syntax
   (test-group "syntactic"
     (define-bytestructure-accessors (bs:vector 3 uint16)
       unwrapper getter setter)
     (define bv (make-bytevector 6))
     (bytevector-u16-native-set! bv 2 321)
     (test-eqv "ref" 321 (getter bv 1))
     (test-eqv "set" 456 (begin (setter bv 1 456)
                                (getter bv 1))))))

(test-group "struct"
  (test-group "aligned"
    (test-assert "create" (bs:struct `((x ,uint8) (y ,uint16))))
    (test-group "procedural"
      (define bs (bytestructure (bs:struct `((x ,uint8) (y ,uint16)))))
      (bytevector-u16-native-set! (bytestructure-bytevector bs) 2 321)
      (test-eqv "ref" 321 (bytestructure-ref bs 'y))
      (test-eqv "set" 456 (begin (bytestructure-set! bs 'y 456)
                                 (bytestructure-ref bs 'y)))
      (test-eqv "init" 321
        (let ((bs (bytestructure (bs:struct `((x ,uint8) (y ,uint16)))
                                 #(123 321))))
          (bytestructure-ref bs 'y))))
    (maybe-skip-syntax
     (test-group "syntactic"
       (define-bytestructure-accessors (bs:struct `((x ,uint8) (y ,uint16)))
         unwrapper getter setter)
       (define bv (make-bytevector 4))
       (bytevector-u16-native-set! bv 2 321)
       (test-eqv "ref" 321 (getter bv y))
       (test-eqv "set" 456 (begin (setter bv y 456)
                                  (getter bv y))))))
  (test-group "packed"
    (test-assert "create" (bs:struct #t `((x ,uint8) (y ,uint16))))
    (test-group "procedural"
      (define bs (bytestructure (bs:struct #t `((x ,uint8) (y ,uint16)))))
      ;; u16-native-set! may error on non-aligned access.
      (guard (err (else (test-skip 3)))
        (bytevector-u16-native-set! (bytestructure-bytevector bs) 1 321))
      (test-eqv "ref" 321 (bytestructure-ref bs 'y))
      (test-eqv "set" 456 (begin (bytestructure-set! bs 'y 456)
                                 (bytestructure-ref bs 'y)))
      (test-eqv "init" 321
        (let ((bs (bytestructure (bs:struct #t `((x ,uint8) (y ,uint16)))
                                 #(123 321))))
          (bytestructure-ref bs 'y))))
    (maybe-skip-syntax
     (test-group "syntactic"
       (define-bytestructure-accessors (bs:struct #t `((x ,uint8) (y ,uint16)))
         unwrapper getter setter)
       (define bv (make-bytevector 4))
       ;; u16-native-set! may error on non-aligned access.
       (guard (err (else (test-skip 2)))
         (bytevector-u16-native-set! bv 1 321))
       (test-eqv "ref" 321 (getter bv y))
       (test-eqv "set" 456 (begin (setter bv y 456)
                                  (getter bv y)))))))

(test-group "union"
  (test-assert "create" (bs:union `((x ,uint8) (y ,uint16))))
  (test-group "procedural"
    (define bs (bytestructure (bs:union `((x ,uint8) (y ,uint16)))
                              '(y 321)))
    (bytevector-u16-native-set! (bytestructure-bytevector bs) 0 321)
    (test-eqv "ref" 321 (bytestructure-ref bs 'y))
    (test-eqv "set" 456 (begin (bytestructure-set! bs 'y 456)
                               (bytestructure-ref bs 'y))))
  (maybe-skip-syntax
   (test-group "syntactic"
     (define-bytestructure-accessors (bs:union `((x ,uint8) (y ,uint16)))
       unwrapper getter setter)
     (define bv (make-bytevector 2))
     (bytevector-u16-native-set! bv 0 321)
     (test-eqv "ref" 321 (getter bv y))
     (test-eqv "set" 456 (begin (setter bv y 456)
                                (getter bv y))))))

(cond-expand
 (guile
  (test-group "pointer"
    (define (protect-from-gc-upto-here obj)
      (with-output-to-file *null-device*
        (lambda ()
          (display (eq? #f obj)))))
    (define pointer-size (ffi:sizeof '*))
    (define bytevector-address-set!
      (case pointer-size
        ((1) bytevector-u8-set!)
        ((2) bytevector-u16-native-set!)
        ((4) bytevector-u32-native-set!)
        ((8) bytevector-u64-native-set!)))
    (test-assert "create" (bs:pointer uint16))
    (test-group "procedural"
      (define bs (bytestructure (bs:pointer uint16)))
      (define bv1 (make-bytevector 2))
      (define address (ffi:pointer-address (ffi:bytevector->pointer bv1)))
      (bytevector-address-set! (bytestructure-bytevector bs) 0 address)
      (bytevector-u16-native-set! bv1 0 321)
      (test-eqv "ref" 321 (bytestructure-ref bs '*))
      (test-eqv "set" 456 (begin (bytestructure-set! bs '* 456)
                                 (bytestructure-ref bs '*)))
      (test-eqv "ref2" address (bytestructure-ref bs))
      (protect-from-gc-upto-here bv1)
      (let* ((bv2 (make-bytevector 2 123))
             (address (ffi:pointer-address (ffi:bytevector->pointer bv2))))
        (test-eqv "set2" address (begin (bytestructure-set! bs address)
                                        (bytestructure-ref bs)))
        (protect-from-gc-upto-here bv2)))
    (test-group "syntactic"
      (define-bytestructure-accessors (bs:pointer uint16)
        unwrapper getter setter)
      (define bv (make-bytevector pointer-size))
      (define bv1 (make-bytevector 2))
      (define address (ffi:pointer-address (ffi:bytevector->pointer bv1)))
      (bytevector-address-set! bv 0 address)
      (bytevector-u16-native-set! bv1 0 321)
      (test-eqv "ref" 321 (getter bv *))
      (test-eqv "set" 456 (begin (setter bv * 456)
                                 (getter bv *)))
      (test-eqv "ref2" address (getter bv))
      (protect-from-gc-upto-here bv1)
      (let* ((bv2 (make-bytevector 2 123))
             (address (ffi:pointer-address (ffi:bytevector->pointer bv2))))
        (test-eqv "set2" address (begin (setter bv address)
                                        (getter bv)))
        (protect-from-gc-upto-here bv2)))))
 (else
  ))

(test-end "bytestructures")

;; Local Variables:
;; eval: (put (quote test-group) (quote scheme-indent-function) 1)
;; eval: (put (quote test-=) (quote scheme-indent-function) 2)
;; End:
