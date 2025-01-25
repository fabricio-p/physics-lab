#lang racket/base

(require racket/match
         racket/format
         racket/list

         (only-in math sqr)
         math/array
         (only-in racket/function curry)

         plot
         (only-in plot/utils ->color)

         "util.rkt")

(define c.g 9.81)

(define m.hs (array #[0.65 0.55 0.45 0.35]))
(define m.tss (array-axis-swap
               (array #[#[7.35 7.34 7.35]
                        #[6.78 6.38 6.50]
                        #[5.81 5.82 5.81]
                        #[5.09 5.00 5.03]])
               0
               1))
(define m.t0s (array #[0.030 0.032 0.036 0.043]))

(define p.r 2.5e-3)
(define p.2r (* 2 p.r))
(define p.m 0.514)

(define (velocities r t0s)
  (array/ (array #[(* 2 r)]) t0s))

(define (moment-of-inertias g m r hs vs)
  (array* (array #[(* m (sqr r))])
          (array- (array/ (array* (array #[(* 2 g)]) hs) (array-sqr vs))
                  (array #[1]))))

(define (accelerations g m r I_zs)
  (array/ (array #[(* m g)])
          (array+ (array #[m])
                  (array/ I_zs (array #[(sqr r)])))))

(define (heights g m r I_zs ts)
  (array* (array-sqr ts)
          (array/ (array #[(* m g)])
                  (array+ (array #[m])
                          (array/ I_zs (array #[(sqr r)]))))))

(module+ main
  (require racket/match
           (only-in math pi)
           (only-in racket/function curry curryr)
           (only-in racket/file make-directory*)

           metapict
           metapict/crop
           latex-pict
           racket-poppler/render-tex
           "figures.rkt"
           "main.rkt")

  (latex-path
   "/home/fabricio/installed/latex/texlive/2024/bin/x86_64-linux/pdflatex")

  (define avg-ts (rows-mean m.tss))
  (define vs (velocities p.r m.t0s))
  (define I_zs (moment-of-inertias c.g p.m p.r m.hs vs))
  (define as (accelerations c.g p.m p.r I_zs))
  (define hs (heights c.g p.m p.r I_zs avg-ts))
  (define mghs (array* m.hs (array #[(* p.m c.g)])))
  (define E_krrs (array/ (array* I_zs (array-sqr vs)) (array #[(* 2 (sqr p.r))])))
  (define E_kts (array/ (array* (array #[p.m]) (array-sqr vs)) (array #[2])))
  (define E_ks (array+ E_krrs E_kts))

  (define output-directory
    (resolve-path (string->path "./exercise-results/exercise-4")))
  (make-directory* output-directory)

  (displayln I_zs)
  (displayln vs)

  (match-define (regression-estimate a v0 _ _)
    (simple-linear-regression avg-ts vs))

  (define diagram-1
    (parameterize ([curve-pict-window (window 0 3.5 0.5 4)]
                   [curve-pict-width 600]
                   [curve-pict-height 600]
                   [ahflankangle 0])
      (crop/inked
       (draw
        ; (color "white" (fill (square (pt 0 0) 4)))
        (penwidth 4 (draw (circle (pt 1.75 1) 0.5)
                          (curve (pt 2.25 1) -- (pt 2.25 3.75))))
        (label-top (tex-math "O") (pt 2.25 3.76))
        (label-rt (tex-math "h") (pt 2.3 2.5))
        (label-rt (tex-math "\\mathrm{d} h") (pt 2.3 1))
        (penwidth 2
                  (color
                   "black"
                   (draw
                    (angle-diagram (pt 1.75 1) (vec 0.2 0) (/ pi 8)
                                   (tex-math "\\mathrm{d}\\varphi"))
                    (curve (pt 1.75 1) -- (pt 2.25 1))
                    (arrow-diagram (pt 1.75 1)
                                   (vec-rotate (vec 0.5 0) (/ pi 8)))))))
       #:padding '(30 30))))
  (save-pict (build-path output-directory "diagram-1.png") diagram-1)

  (parameterize ([base-directory output-directory])
    (write-json-to
     "data.json"
     `#hasheq([hs . ,(array->list m.hs)]
              [avg-ts . ,(array->list avg-ts)]
              [avg-a . ,(array-all-mean as)]
              [reg-a . ,a]
              [reg-v0 . ,v0]
              [I_zs . ,(array->list I_zs)]
              [avg-I_z . ,(array-all-mean I_zs)]
              [vs . ,(array->list vs)]
              [avg-t . ,(array-all-mean avg-ts)]
              [avg-v . ,(array-all-mean vs)]
              [mghs . ,(array->list mghs)]
              [E_krrs . ,(array->list E_krrs)]
              [E_kts . ,(array->list E_kts)]
              [E_ks . ,(array->list E_ks)])))

  (let ([vs-points (map list
                        (array->list avg-ts)
                        (array->list vs))]
        [m.hs-points (map list
                          (array->list avg-ts)
                          (array->list m.hs))]
        [math-scale 0.8])
    (parameterize ([plot-width 620]
                   [plot-height 480]

                   [plot-x-label (scale math-scale (tex-math "t"))]
                   [plot-y-label (scale math-scale (tex-math "h~(\\mathrm{m})"))]
                   [plot-x-far-axis? #f]
                   [plot-y-far-axis? #t]
                   [plot-y-far-label
                    (scale math-scale
                           (tex-math "v~(\\mathrm{m}/\\mathrm{s})"))]
                   [plot-x-ticks (fraction-ticks 0.2 5 #:precision 1)]
                   [plot-y-ticks (fraction-ticks 0.02 5 #:precision 2)])
      (plot
       (list (tick-grid)
             (axes)
             (points m.hs-points
                     #:color (->color "red")
                     #:fill-color (->color "red")
                     #:sym 'fulltriangle
                     #:size 13)
             (function (λ (t) (+ (* a (sqr t) 0.5) (* v0 t)))
                       0
                       (ceiling (array-all-max avg-ts))
                       #:label (scale math-scale
                                      (tex-math "h(t) = \\frac{at^2}2 + bt"))
                       #:color "red"
                       #:width 2)
             (for/list ([coords m.hs-points])
               (point-label
                coords
                (~a "("  (~r (first coords) #:precision 3)
                    ", " (~r (second coords) #:precision 3) ")")
                #:anchor 'right
                #:point-color "red"
                #:point-fill-color "red"
                #:point-sym 'fulltriangle
                #:point-size 13))

             (points vs-points
                     #:color (->color "blue")
                     #:fill-color (->color "blue")
                     #:sym 'fulltriangle
                     #:size 13)

             (function (λ (t) (+ (* a t) v0))
                       0
                       (add1 (ceiling (array-all-max avg-ts)))
                       #:label (scale math-scale
                                      (tex-math "v = at + b"))
                       #:color "blue"
                       #:width 2)
             (for/list ([coords vs-points]
                        [anchor '(bottom bottom-right top-left top-right)])
               (point-label
                coords
                (~a "("  (~r (first coords) #:precision 3)
                    ", " (~r (second coords) #:precision 3) ")")
                #:anchor anchor
                #:point-color "blue"
                #:point-fill-color "blue"
                #:point-sym 'fulltriangle
                #:point-size 13)))
       #:out-file (build-path output-directory "plot-1.jpg"))))

  #|(parameterize ([plot-new-window? #t]
                 [plot-width 700]
                 [plot-height 500]
                 [plot-x-far-axis? #f]
                 [plot-y-far-axis? #f])
    (let ([as-points (map list
                          (array->list avg-ts)
                          (array->list as))]
          [I_zs-points (map list
                            (array->list m.hs)
                            (array->list I_zs))]
          [vs-points (map list
                          (array->list avg-ts)
                          (array->list vs))]
          [m.hs-points (map list
                            (array->list avg-ts)
                            (array->list m.hs))]
          [hs-points (map list
                          (array->list avg-ts)
                          (array->list hs))]
          [math-scale 2])

      (parameterize ([plot-x-label (scale math-scale (tex-math "t"))]
                     [plot-y-label (scale math-scale (tex-math "a"))]
                     [plot-x-ticks (fraction-ticks 0.1 10 #:precision 1)]
                     [plot-y-ticks (fraction-ticks 0.001 10 #:precision 3)])
        (plot
         (list (tick-grid)
               (axes)
               (points as-points
                       #:color (->color "green")
                       #:fill-color (->color "green")
                       #:sym 'fulltriangle
                       #:size 13))
         #:x-min 0
         #:y-min 0))

      (parameterize ([plot-x-label (scale math-scale (tex-math "h"))]
                     [plot-y-label (scale math-scale (tex-math "I_z"))]
                     [plot-x-ticks (fraction-ticks 0.01 10 #:precision 2)]
                     [plot-y-ticks (fraction-ticks 0.0001 10 #:precision 4)])
        (plot
         (list (tick-grid)
               (axes)
               (points I_zs-points
                       #:color (->color "red")
                       #:fill-color (->color "red")
                       #:sym 'fulltriangle
                       #:size 13))
         #:x-min 0
         #:y-min 0))

      (parameterize ([plot-x-label (scale math-scale (tex-math "t"))]
                     [plot-y-label (scale math-scale (tex-math "h(t)"))]
                     [plot-x-ticks (fraction-ticks 0.1 10 #:precision 1)]
                     [plot-y-ticks (fraction-ticks 0.01 10 #:precision 2)])
        (plot
         (list (tick-grid)
               (axes)
               (points m.hs-points
                       #:color (->color "black")
                       #:fill-color (->color "black")
                       #:sym 'fulltriangle
                       #:size 13)

               (points hs-points
                       #:color (->color "red")
                       #:fill-color (->color "red")
                       #:sym 'fulltriangle
                       #:size 13)

               (function (λ (t) (+ (* a (sqr t) 0.5) (* v0 t)))
                         0
                         (ceiling (array-all-max avg-ts))
                         #:label (scale (/ math-scale 2)
                                        (tex-math "h(t) = \\frac{at^2}2 + v_0t"))
                         #:color "red"
                         #:width 2)
               (for/list ([coords hs-points])
                     (point-label
                      coords
                      (~a "("  (~r (first coords) #:precision 5)
                          ", " (~r (second coords) #:precision 1) ")")
                      #:anchor 'right
                      #:point-color "red"
                      #:point-fill-color "red"
                      #:point-sym 'fulltriangle
                      #:point-size 13)))
         #:x-min 0
         #:y-min 0))

      (parameterize ([plot-x-label (scale math-scale (tex-math "t"))]
                     [plot-y-label (scale math-scale (tex-math "v(t)"))]
                     [plot-x-ticks (fraction-ticks 0.1 10 #:precision 2)]
                     [plot-y-ticks (fraction-ticks 0.01 10 #:precision 2)])
        (plot
         (list (tick-grid)
               (axes)
               (points vs-points
                       #:color (->color "blue")
                       #:fill-color (->color "blue")
                       #:sym 'fulltriangle
                       #:size 13)

               (function (λ (t) (+ (* a t) v0))
                         0
                         (ceiling (array-all-max avg-ts))
                         #:label (scale (/ math-scale 2)
                                        (tex-math "v = at + v_0"))
                         #:color "blue"
                         #:width 2)
               (function (λ (t) (* a t))
                         0
                         (ceiling (array-all-max avg-ts))
                         #:label (scale (/ math-scale 2)
                                        (tex-math "v = at"))
                         #:color "cyan"
                         #:width 2)
               (for/list ([coords vs-points])
                     (point-label
                      coords
                      (~a "("  (~r (first coords) #:precision 5)
                          ", " (~r (second coords) #:precision 1) ")")
                      #:anchor 'right
                      #:point-color "blue"
                      #:point-fill-color "blue"
                      #:point-sym 'fulltriangle
                      #:point-size 13)))
         #:x-min 0
         #:y-min 0))))|#)
