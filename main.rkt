#lang racket/base

(require racket/contract
         racket/function
         racket/match
         racket/list
         racket/format

         (except-in math permutations variance covariance)
         math/array

         plot
         (only-in plot/utils ->color)

         "util.rkt")

(provide fraction-ticks)

(define/contract (fraction-ticks step bound #:precision [precision 1])
    (->* (inexact? positive-integer?)
         (#:precision exact-nonnegative-integer?)
         ticks?)

    (ticks (λ (low high)
             (for/list ([t (range
                            (sub1 (floor low))
                            (add1 (inexact->exact (/ (- high low) step))))])
               (let ([value (+ low (* t step))])
                 (pre-tick value (= (remainder t bound) 0)))))
           (λ (low high pre-ticks)
             (for/list ([pre-tick pre-ticks])
               (~r (pre-tick-value pre-tick) #:precision precision)))))

(module+ test
  (require rackunit))
