;;; numeric.scm --- Numeric types as supported by (rnrs bytevectors).

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

;; This module defines descriptors for numeric types of specific size, and
;; native or specific endianness, as made possible by the bytevector referencing
;; and assigning procedures in the (rnrs bytevectors) module.


;;; Code:

(define-syntax define-numeric-types
  (syntax-rules ()
    ((_ (name size getter setter) ...)
     (begin
       (define name
         (make-bytestructure-descriptor
          size size
          #f
          (lambda (syntax? bytevector offset)
            (if syntax?
                (quasisyntax
                 (getter (unsyntax bytevector) (unsyntax offset)))
                (getter bytevector offset)))
          (lambda (syntax? bytevector offset value)
            (if syntax?
                (quasisyntax
                 (setter (unsyntax bytevector) (unsyntax offset)
                         (unsyntax value)))
                (setter bytevector offset value)))))
       ...))))

(define-numeric-types
  (float32
   4 bytevector-ieee-single-native-ref bytevector-ieee-single-native-set!)
  (double64
   8 bytevector-ieee-double-native-ref bytevector-ieee-double-native-set!)
  (int8   1 bytevector-s8-ref bytevector-s8-set!)
  (uint8  1 bytevector-u8-ref bytevector-u8-set!)
  (int16  2 bytevector-s16-native-ref bytevector-s16-native-set!)
  (uint16 2 bytevector-u16-native-ref bytevector-u16-native-set!)
  (int32  4 bytevector-s32-native-ref bytevector-s32-native-set!)
  (uint32 4 bytevector-u32-native-ref bytevector-u32-native-set!)
  (int64  8 bytevector-s64-native-ref bytevector-s64-native-set!)
  (uint64 8 bytevector-u64-native-ref bytevector-u64-native-set!))

(define-syntax define-with-endianness
  (syntax-rules ()
    ((_ (name native-name size getter setter endianness) ...)
     (begin
       (define name
         (if (equal? endianness native-endianness)
             native-name
             (make-bytestructure-descriptor
              size size
              #f
              (lambda (syntax? bytevector offset)
                (if syntax?
                    (quasisyntax
                     (getter (unsyntax bytevector) (unsyntax offset)))
                    (getter bytevector offset)))
              (lambda (syntax? bytevector offset value)
                (if syntax?
                    (quasisyntax
                     (setter (unsyntax bytevector) (unsyntax offset)
                             (unsyntax value)))
                    (setter bytevector offset value))))))
       ...))))

(define-syntax define-with-endianness*
  (syntax-rules ()
    ((_ (native-name size
                     le-name le-getter le-setter
                     be-name be-getter be-setter) ...)
     (begin
       (define-with-endianness
         (le-name native-name size
                  le-getter le-setter (endianness little))
         (be-name native-name size
                  be-getter be-setter (endianness big)))
       ...))))

(define-with-endianness*
  (float32
   4
   float32le bytevector-ieee-single-le-ref bytevector-ieee-single-le-set!
   float32be bytevector-ieee-single-be-ref bytevector-ieee-single-be-set!)
  (double64
   8
   double64le bytevector-ieee-double-le-ref bytevector-ieee-double-le-set!
   double64be bytevector-ieee-double-be-ref bytevector-ieee-double-be-set!)
  (int16 2
         int16le bytevector-s16le-ref bytevector-s16le-set!
         int16be bytevector-s16be-ref bytevector-s16be-set!)
  (uint16 2
          uint16le bytevector-u16le-ref bytevector-u16le-set!
          uint16be bytevector-u16be-ref bytevector-u16be-set!)
  (int32 4
         int32le bytevector-s32le-ref bytevector-s32le-set!
         int32be bytevector-s32be-ref bytevector-s32be-set!)
  (uint32 4
          uint32le bytevector-u32le-ref bytevector-u32le-set!
          uint32be bytevector-u32be-ref bytevector-u32be-set!)
  (int64 8
         int64le bytevector-s64le-ref bytevector-s64le-set!
         int64be bytevector-s64be-ref bytevector-s64be-set!)
  (uint64 8
          uint64le bytevector-u64le-ref bytevector-u64le-set!
          uint64be bytevector-u64be-ref bytevector-u64be-set!))

;;; numeric.scm ends here
