#lang racket/base

(require racket/match
         racket/contract
         (only-in racket/function curry)

         math
         math/array

         json
         csv-writing)

(provide base-directory call-with-fresh-out-file write-csv-to
         write-json-to

         covariance variance array-mean array-all-mean rows-mean

         (struct-out regression-estimate) simple-linear-regression)

(define base-directory (make-parameter #f))

(define (call-with-fresh-out-file path cb)
  (call-with-output-file
    (match (base-directory)
      [#f path]
      [base (build-path base path)]) cb #:exists 'truncate/replace))
(define (write-csv-to path csv)
  (call-with-fresh-out-file path (curry display-table csv)))
(define (write-json-to path json)
  (call-with-fresh-out-file path (curry write-json json)))

(define (covariance xs ys avg-x avg-y)
  (array-all-mean (array*
                   (array- xs (array #[avg-x]))
                   (array- ys (array #[avg-y])))))

(define (variance xs avg-x)
  (array-all-mean (array-sqr (array- xs (array #[avg-x])))))

(define (array-all-mean arr)
  (/ (array-all-sum arr) (array-size arr)))

(define (rows-mean xs)
  (match-let ([(vector rows _) (array-shape xs)])
    (array/ (array-axis-sum xs 0) (array #[(exact->inexact rows)]))))

(define (array-mean xs axis)
  (define n (vector-ref (array-shape xs) axis))
  (array/ (array-axis-sum xs axis) (array #[(exact->inexact n)])))

(struct regression-estimate (a b std-a std-b) #:transparent)

(define xs/c (and/c array? (compose (curry = 1) array-dims)))
(define (ys/c xs) (compose (curry = (array-size xs)) array-size))

(define/contract (simple-linear-regression xs ys)
  (->i ([xs xs/c]
        [ys (xs) (ys/c xs)])
       [result regression-estimate?])

  (let ([avg-x (array-all-mean xs)]
        [avg-y (array-all-mean ys)])
    (letrec ([var-x (variance xs avg-x)]
             [a (/ (covariance xs ys avg-x avg-y) var-x)]
             [b (- avg-y (* a avg-x))]
             [std-a (sqrt (/ (- (/ (variance ys avg-y) var-x) (sqr b))
                        (- (array-size xs) 2)))]
             [std-b (sqrt (- (sqr avg-x) var-x))])
      (regression-estimate a b std-a std-b))))

