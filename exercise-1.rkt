#lang racket/base

(require racket/format
         racket/match
         (only-in racket/list first second)
         (only-in racket/function curry)
         math/array
         
         (except-in plot fraction-ticks)
         (only-in plot/utils ->color)
         (rename-in (only-in pict scale) [scale scale-pict])
         latex-pict
         racket-poppler/render-tex

         csv-writing
         json

         "main.rkt"
         "util.rkt")

(latex-path "/home/fabricio/installed/latex/texlive/2024/bin/x86_64-linux/pdflatex")

(require "figures.rkt")

(define (acceleration xs ts)
  (array/ (array* (array #[2]) xs) (array-sqr ts)))

(define (absolute-error xs [avg-x #f])
  (let ([avg-x (if avg-x avg-x (array-all-mean xs))])
    (array-all-sum (array-abs (array- (array #[avg-x]) xs)))))

(define (mean-absolute-error xs [avg-x #f])
  (/ (absolute-error xs avg-x) (array-size xs)))

(define (plot-exercise-graph
         xs ys
         #:name [name #f]
         #:regression-x-min-function [x-min-fn #f]
         #:x-max [x-max #f]
         #:y-max [y-max #f]
         #:x-min [x-min 1]
         #:y-min [y-min #f]
         #:regression-name [rname #f]
         #:out-file [out-file #f])

  (let ([graph-points (map list
                           (array->list xs)
                           (array->list ys))])
    
    (plot (list (tick-grid)
                (axes)
                (if name
                    (points graph-points
                            #:label name
                            #:color (->color "green")
                            #:fill-color (->color "green")
                            #:sym 'fulltriangle
                            #:size 13)
                    '())
                (if rname
                    (match-let ([(regression-estimate a b std-a std-b)
                                 (simple-linear-regression xs ys)])
                      (define (f x) (+ (* a x) b))
                      (define (f-1 x) (/ (- x b) a))
                      
                      (function f
                                (if x-min-fn (x-min-fn f f-1 a b) 0)
                                (cond
                                  [y-max (f-1 y-max)]
                                  [x-max x-max]
                                  [else
                                   (/ (ceiling (* (array-all-max xs) 10)) 10)])
                                #:label rname
                                #:color (->color "blue")
                                #:width 2))
                    '())
                (for/list ([coords graph-points])
                  (point-label
                   coords
                   (~a "("  (~r (first coords) #:precision 5)
                       ", " (~r (second coords) #:precision 1) ")")
                   #:anchor 'right
                   #:point-color (->color "green")
                   #:point-fill-color (->color "green")
                   #:point-sym 'fulltriangle
                   #:point-size 13)))
          #:x-max x-max
          #:y-max y-max
          #:x-min x-min
          #:y-min y-min
          #:out-file out-file)))

(define delta-xs (array #[0.8 0.7 0.6 0.5]))

(define ts-1 (array #[#[3.90 3.00 2.98 2.13]
                      #[3.56 3.19 2.75 2.43]
                      #[3.38 3.18 2.85 2.41]
                      #[3.66 3.13 2.71 2.51]]))

(define ts-2 (array #[#[2.63 2.33 2.11 1.83]
                      #[2.68 2.41 2.15 1.96]
                      #[2.50 2.20 2.17 1.85]
                      #[2.65 2.28 2.06 1.79]]))


(module+ main
  (require (only-in racket/file make-directory*)
           metapict
           (only-in math sqr))
  
  (define avg-tss (map rows-mean (list ts-1 ts-2)))
  (define ass (map (curry acceleration delta-xs) avg-tss))
  (define vss (map (λ (as avg-ts) (array* as avg-ts)) ass avg-tss))
  (define avg-as (map array-all-mean ass))
  (define as-abs-err (map mean-absolute-error ass avg-as))
  (define as-rel-err (map / as-abs-err avg-as))

  (define output-directory
    (resolve-path (string->path "exercise-results/exercise-1")))
  (make-directory* output-directory)

  (define (draw-plots base-dir avg-tss delta-xs vss avg-as)
    (parameterize ([plot-width 700]
                   [plot-height 500]
                   [plot-x-far-axis? #f]
                   [plot-y-far-axis? #f])

      (for ([xs avg-tss]
            [ys (list delta-xs delta-xs)]
            [avg-a avg-as]
            [out-file '("plot-1.jpg" "plot-2.jpg")])
        (let ([graph-points (map list
                                 (array->list xs)
                                 (array->list ys))]
              [math-scale 1.3])

          (parameterize ([plot-x-label (scale math-scale (tex-math "t"))]
                         [plot-y-label (scale math-scale (tex-math "S~"))]
                         [plot-x-ticks (fraction-ticks 0.1 5 #:precision 2)]
                         [plot-y-ticks (fraction-ticks 0.05 2 #:precision 2)])
            (plot
             (list (tick-grid)
                   (axes)
                   (points graph-points
                           #:label (scale
                                    math-scale
                                    (tex-math "S \\ \\mathrm{e \\ matur}"))
                           #:color (->color "green")
                           #:fill-color (->color "green")
                           #:sym 'fulltriangle
                           #:size 13)
                   (function (λ (t) (* avg-a (sqr t) 0.5))
                             0
                             (ceiling (array-all-max xs))
                             #:label (scale
                                      math-scale
                                      (tex-math
                                       "S = \\frac{\\overline{a} t^2} 2"))
                             #:color (->color "red")
                             #:width 2)
                   (for/list ([coords graph-points])
                     (point-label
                      coords
                      (~a "("  (~r (first coords) #:precision 5)
                          ", " (~r (second coords) #:precision 1) ")")
                      #:anchor 'right
                      #:point-color (->color "green")
                      #:point-fill-color (->color "green")
                      #:point-sym 'fulltriangle
                      #:point-size 13)))
             #:out-file (build-path base-dir out-file)))))

      (for ([xs avg-tss]
            [ys vss]
            [avg-a avg-as]
            [out-file '("plot-3.jpg" "plot-4.jpg")])
        (let ([graph-points (map list
                                 (array->list xs)
                                 (array->list ys))]
              [math-scale 1.3]
              [point-color (->color "black")]
              [line-color (->color "blue")])

          (parameterize ([plot-x-label (scale math-scale (tex-math "t"))]
                         [plot-y-label (scale math-scale (tex-math "v~"))]
                         [plot-x-ticks (fraction-ticks 0.1 5 #:precision 2)]
                         [plot-y-ticks (fraction-ticks 0.05 2 #:precision 2)])
            (plot
             (list (tick-grid)
                   (axes)
                   (points graph-points
                           #:label (scale
                                    math-scale
                                    (tex-math "v \\ \\mathrm{e \\ llogaritur}"))
                           #:color point-color
                           #:fill-color point-color
                           #:sym 'fulltriangle
                           #:size 13)
                   (function (λ (t) (* avg-a t))
                             (floor (array-all-min xs))
                             (ceiling (array-all-max xs))
                             #:label (scale
                                      math-scale
                                      (tex-math
                                       "v = \\overline{a} t"))
                             #:color line-color
                             #:width 2)
                   (for/list ([coords graph-points])
                     (point-label
                      coords
                      (~a "("  (~r (first coords) #:precision 5)
                          ", " (~r (second coords) #:precision 1) ")")
                      #:anchor 'right
                      #:point-color point-color
                      #:point-fill-color point-color
                      #:point-sym 'fulltriangle
                      #:point-size 13)))
             #:out-file (build-path base-dir out-file)))))))

  (draw-plots output-directory avg-tss delta-xs vss avg-as)

  (parameterize ([base-directory output-directory])
    (let* ([avg-tss (map array->list avg-tss)]
           [ass (map array->list ass)]
           [vss (map array->list vss)])
      (write-json-to
       "data.json"
       `#hasheq([delta-xs . ,(array->list delta-xs)]
                [avg-tss . ,avg-tss]
                [ass . ,ass]
                [avg-as . ,avg-as]
                [as-abs-err . ,as-abs-err]
                [as-rel-err . ,as-rel-err]
                [vss . ,vss]))))

  (define ($ str [scale-factor 1.5] #:preamble [preamble (current-preamble)])
    (scale scale-factor (tex-math str #:preamble preamble)))

  (define (overrightarrow str) (~a "\\overrightarrow{\\rule[10pt]{0pt}{0pt}{" str "}}"))

  (default-normal-vec (struct-copy vector-arrow (default-normal-vec)
                                   [name ($ (~a (overrightarrow "F") "_N"))]
                                   [thickness 1.5]))

  (define figure-1
    (parameterize ([curve-pict-window (window 0 4 0 4)]
                   [curve-pict-width 600]
                   [curve-pict-height 600]
                   [ahflankangle 0])
      (draw
       ; (color "white" (fill (square (pt 0 0) 4)))
       (slope-force-diagram
        (pt 0 0.5) 4 1.5 (round-object 0.7) 0.7
        #:object-color (color-med 0.15 "white" "black")
        #:slope (make-slope-config #:color (color-med 0.2 "white" "black")
                                   #:line-color "black"
                                   #:line-thickness 1)
        #:gravity-vec (let ([decompose-color (color-med 0.4 "white" "black")]
                            [vec-name (curry ~a (~a (overrightarrow "F") "_g"))])
                        (make-diagram-vector
                         #:color "black"
                         #:name ($ (vec-name ""))
                         #:length 2
                         #:thickness 3
                         #:decompose-x (make-vector-arrow
                                        #:color decompose-color
                                        #:name ($ (vec-name "\\sin \\theta"))
                                        #:thickness 8)
                         #:decompose-y (make-vector-arrow
                                        #:color decompose-color
                                        #:name ($ (vec-name "\\cos \\theta"))
                                        #:thickness 8)))
        #:object-center-circle (px 2.7)
        #:force-vec #f
        #:friction-vec (make-vector-arrow
                        #:color (color-med 0.65 "white" "black")
                        #:name ($ (~a (overrightarrow "f") "_s"))
                        #:thickness 5)
        #:friction-direction 'up
        #:theta (make-diagram-angle ($ "\\theta") 'all)))))

  (save-pict (build-path output-directory "diagram-1.png") figure-1))



; TODO: Output the regression data to some json file

