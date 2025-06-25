#lang racket/base

(require racket/match
         racket/list
         racket/file
         math/array

         (except-in plot fraction-ticks)
         (only-in metapict scale)
         latex-pict
         racket-poppler/render-tex

         "util.rkt"
         "main.rkt")

(latex-path
   "/home/fabricio/installed/latex/texlive/2024/bin/x86_64-linux/pdflatex")

(define output-directory
  (resolve-path (string->path "./exercise-results/exercise-21")))
(make-directory* output-directory)

(define math-scale 1)

(define p.C (array #[2 4 6 9]))
(define m.n (array #[1.336 1.339 1.342 1.346]))

(define nₓ 1.344)

(match-define (regression-estimate a b std-a std-b)
  (simple-linear-regression p.C m.n))

(define (f x) (+ (* x a) b))
(define (f⁻¹ x) (/ (- x b) a))

(define pₓ (list (f⁻¹ nₓ) nₓ))

(write-json-to (build-path output-directory "data.json")
               `#hasheq([C_x . ,(first pₓ)]
                        [a . ,a]
                        [b . ,b]))

(parameterize ([plot-width 500]
               [plot-height 410]
               [plot-x-label "Përqëndrimi (%)"]
               [plot-y-label (scale math-scale (tex-math "n~"))]
               [plot-x-far-axis? #f]
               [plot-y-far-axis? #f]
               [plot-x-ticks (fraction-ticks 0.5 2 #:precision 1)]
               [plot-y-ticks (fraction-ticks 1e-3 5 #:precision 4)])
  (let ([graph-points (map list (array->list p.C) (array->list m.n))])
    (plot (list (tick-grid)
                (axes)
                (function f #:color "red")
                (points graph-points #:sym 'fullcircle #:size 7)
                (for/list ([p graph-points])
                  (point-label p (format "(~a, ~a)" (first p) (second p))
                               #:anchor 'bottom-right))
                (points (list pₓ) #:sym 'fulltriangle #:size 13)
                (point-label pₓ (format "(~a, ~a)"
                                        (/ (round (* 1e3 (first pₓ))) 1e3)
                                        (second pₓ))
                             #:anchor 'bottom-right))
          #:x-min 0
          #:y-min 1.330
          #:x-max 10
          #:y-max 1.350
          #:out-file (build-path output-directory "plot-1.jpg"))))
