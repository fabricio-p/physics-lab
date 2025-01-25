#lang racket/base

(require racket/match
         racket/format
         racket/list

         math/array
         (only-in racket/function curry)

         plot
         (only-in plot/utils ->color)

         "util.rkt")


(define p.ls (array #[0.3 0.4 0.5 0.6 0.7 0.8]))
(define p.n 10)
(define m.tss (array #[#[11.61 13.24 14.60 15.85 17.28 18.22]
                       #[11.72 13.31 14.68 15.84 17.12 18.18]
                       #[11.67 13.30 14.70 15.73 11.17 18.20]
                       #[11.65 13.25 14.64 15.75 19.06 18.25]]))

(module+ main
  (require racket/match
           racket/file
           (only-in racket/function curry curryr)
           (only-in racket/file make-directory*)
           racket/class
           (only-in racket/draw brush%)
           (only-in math pi sqr)

           (except-in plot inverse fraction-ticks)
           metapict
           metapict/crop
           latex-pict
           racket-poppler/render-tex

           "main.rkt")

  (latex-path "/home/fabricio/installed/latex/texlive/2024/bin/x86_64-linux/pdflatex")

  (require "figures.rkt")

  (define (overrightarrow str) (~a "\\overrightarrow{\\rule[10pt]{0pt}{0pt}{" str "}}"))

  ; TODO: Finish
  (define avg-ts (rows-mean m.tss))
  (define Ts (array/ avg-ts (array #[p.n])))

  (define gs (array/ (array* (array #[(* 4 (sqr pi))]) p.ls)
                     (array-sqr Ts)))
  (define avg-g (array-all-mean gs))
  (define abs-err-g (array-all-mean (array-abs (array- (array #[avg-g]) gs))))
  (define rel-err-g (/ abs-err-g avg-g))

  (define output-directory
    (resolve-path (string->path "./exercise-results/exercise-2")))
  (make-directory* output-directory)

  (match-define (regression-estimate a b _ _)
    (simple-linear-regression p.ls Ts))

  (parameterize ([base-directory output-directory])
    (write-json-to
     "data.json"
     `#hasheq([ls . ,(array->list p.ls)]
              [avg-ts . ,(array->list avg-ts)]
              [Ts . ,(array->list Ts)]
              [gs . ,(array->list gs)]
              [avg-g . ,avg-g]
              [abs-err-g . ,abs-err-g]
              [rel-err-g . ,rel-err-g])))

  (let ([plot-points (map list (array->list p.ls) (array->list Ts))]
        [math-scale 0.8])
    (parameterize ([plot-width 620]
                   [plot-height 480]
                   [plot-x-label (scale math-scale (tex-math "l"))]
                   [plot-y-label (scale math-scale (tex-math "T"))]
                   [plot-x-far-axis? #f]
                   [plot-y-far-axis? #f]
                   [plot-x-ticks (fraction-ticks 0.05 2 #:precision 3)]
                   [plot-y-ticks (fraction-ticks 0.05 10 #:precision 2)])
      (plot
       (list (tick-grid)
             (axes)
             (points plot-points
                     #:color (->color "red")
                     #:fill-color (->color "red")
                     #:sym 'fulltriangle
                     #:size 13)
             (function (λ (t) (+ (* a t) b))
                       ((compose (curryr / 10) sub1 (curry * 10))
                        (array-all-min p.ls))
                       (ceiling (array-all-max p.ls))
                       #:color "red"
                       #:width 2)
             (for/list ([coords plot-points])
               (point-label
                coords
                (~a "("  (~r (first coords) #:precision 3)
                    ", " (~r (second coords) #:precision 3) ")")
                #:anchor 'top-left
                #:point-color "red"
                #:point-fill-color "red"
                #:point-sym 'fulltriangle
                #:point-size 13)))
       #:out-file (build-path output-directory "plot-1.jpg")
       #:x-min 0.2
       #:y-min 1)))

  (define diagram-1
    (parameterize ([curve-pict-window (window 0 9 0 9)]
                   [curve-pict-width 600]
                   [curve-pict-height 600]
                   [ahflankangle 0]
                   [ahlength (px 5)])
      (crop/inked
       (draw
        ; (color "white" (fill (rectangle (pt 0 0) (vec 4.5 8.75))))
        (pendulum-force-diagram
         (round-object 0.3) (pt 1 8.25) 5.5 (/ pi 9)
         #:gravity-vec (make-diagram-vector
                        #:name (tex-math (overrightarrow "G"))
                        #:color "black"
                        #:length 2.5
                        #:decompose-x (make-vector-arrow
                                       #:name (tex-math (~a (overrightarrow "G") "_x"))
                                       #:color "black")
                        #:decompose-y (make-vector-arrow
                                       #:name (tex-math (~a (overrightarrow "G") "_y"))
                                       #:color "black"))
         #:tension-vec (make-vector-arrow
                        #:name (tex-math (overrightarrow "T"))
                        #:color "black")
         #:position-distance-name (tex-math "x"))
        (brush (new brush% [color "black"] [style 'fdiagonal-hatch])
               (filldraw (rectangle (pt 0.5 8.25) (vec 1 0.5)))))
       #:padding '(40 40))))
  (save-pict (build-path output-directory "diagram-1.png") diagram-1))
