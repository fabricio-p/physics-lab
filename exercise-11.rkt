#lang debug racket/base

(require racket/match
         racket/format
         racket/list
         racket/file
         racket/class
         (only-in racket/function curry curryr)
         ; (only-in racket/file make-directory*)
         (only-in math pi sqr)
         math/array

         (except-in plot inverse fraction-ticks)
         (only-in metapict scale)
         (only-in pict rotate inset)
         latex-pict
         racket-poppler/render-tex
         (only-in plot/utils ->color ->pen-color)

         "util.rkt"
         "main.rkt")

(define ((x-tick-lines-render-proc) area)
  (match-define (vector x-ivl (ivl y-min y-max)) (send area get-bounds-rect))
  (when (and y-min y-max)
    (define x-ticks (send area get-x-ticks))
    (send area put-alpha 1/2)
    (for ([t  (in-list x-ticks)])
      (match-define (tick x major? _) t)
      (parameterize ([plot-foreground (->pen-color '(150 150 150))])
        (send area put-minor-pen)
        (send area put-line (vector x y-min) (vector x y-max))))))

; (a + b + c) / 3 = (a + b + c + x) / 4
; 4a + 4b + 4c = 3a + 3b + 3c + 3x
; a + b + c = 3x

(define ((y-tick-lines-render-proc) area)
  (match-define (vector (ivl x-min x-max) y-ivl) (send area get-bounds-rect))
  (when (and x-min x-max)
    (define y-ticks (send area get-y-ticks))
    (send area put-alpha 1/2)
    (for ([t  (in-list y-ticks)])
      (match-define (tick y major? _) t)
      (parameterize ([plot-foreground (->pen-color '(150 150 150))])      
        (send area put-minor-pen)
        (send area put-line (vector x-min y) (vector x-max y))))))

(define (x-tick-lines)
  (renderer2d #f #f #f #f (x-tick-lines-render-proc)))

(define (y-tick-lines)
  (renderer2d #f #f #f #f (y-tick-lines-render-proc)))

(define (tick-grid-contiguous)
  (list (x-tick-lines) (y-tick-lines)))

(latex-path
   "/home/fabricio/installed/latex/texlive/2024/bin/x86_64-linux/pdflatex")

(define output-directory
  (resolve-path (string->path "./exercise-results/exercise-11")))
(make-directory* output-directory)

(define math-scale 1)

; (define (f μ₀ n N₂ S ω I₀ t)
  

(define data-plot-pairs
  (parameterize ([plot-y-label
                  ((compose (λ (p) (inset p 0 0 10 0))
                            (curryr rotate (/ pi 2))
                            (curry scale math-scale)
                            tex-math)
                   "\\varepsilon_{\\mathrm{ind}} (\\mathrm V)~")])
    (list
     (let ()
       (define p.f 3) ; kHz
       (define p.N_2 300)
       (define p.D 41e-3) ; meters
       ; (define p.I (array/ (array #[10 20 30 40 44 50 52 56 58 60])
       ;                     (array #[1e3]))) ; amperes

       (define p.I (array #[10 20 30 40 44 50 52 56 58 60])) ; miliamps
       (define m.ε_ind (array/ (array #[61 130 195 256 286 318 334 336 337 389])
                               (array #[1e3]))) ; volts

       (match-define (regression-estimate a b std-a std-b)
         (simple-linear-regression p.I m.ε_ind))

       (cons
        `#hasheq([a . ,a] [b . ,b])
        (parameterize ([plot-width 650]
                       [plot-height 450]
                       [plot-x-label (scale math-scale (tex-math "I (\\mathrm{mA})"))]
                       [plot-x-far-axis? #f]
                       [plot-y-far-axis? #f]
                       [plot-x-ticks (fraction-ticks 1.0 10 #:precision 0)]
                       [plot-y-ticks (fraction-ticks 0.01 10 #:precision 2)])
          (let ([graph-points (map list (array->list p.I) (array->list m.ε_ind))])
            (plot
             (list (tick-grid)
                   (axes)
                   (points graph-points #:sym 'asterisk #:size 7)
                   (function (λ (x) (+ (* x a) b))
                             #:color "red"))
             #:x-min 0
             #:y-min 0
             #:x-max 65
             #:y-max 0.4
             #:out-file (build-path output-directory "plot-1.jpg"))))))

     (let ()
       (define p.I 30) ; miliamps
       (define p.N_2 300)
       (define p.D 41e-3) ; meters
       (define p.f (array #[1 2 3 4 5 6 7 8 9 10])) ; kHz
       (define m.ε_ind (array/ (array #[67 102 195 259 318 378 448 484 535 559])
                               (array #[1e3]))) ; volts

       (match-define (regression-estimate a b std-a std-b)
         (simple-linear-regression p.f m.ε_ind))

       (cons
        `#hasheq([a . ,a] [b . ,b])
        (parameterize ([plot-width 610]
                       [plot-height 410]
                       [plot-x-label (scale math-scale (tex-math "I (\\mathrm{mA})"))]
                       [plot-x-far-axis? #f]
                       [plot-y-far-axis? #f]
                       [plot-x-ticks (fraction-ticks 0.2 5 #:precision 1)]
                       [plot-y-ticks (fraction-ticks 0.01 10 #:precision 2)])
          (let ([graph-points (map list (array->list p.f) (array->list m.ε_ind))])
            (plot
             (list (tick-grid-contiguous)
                   (axes)
                   (points graph-points #:sym 'asterisk #:size 7)
                   (function (λ (x) (+ (* x a) b))
                             #:color "red"))
             #:x-min 0
             #:y-min 0
             #:x-max 10.5
             #:y-max 0.6
             #:out-file (build-path output-directory "plot-2.jpg"))))))

     (let ()
       (define p.I 30) ; miliamps
       (define p.f 3) ; kHz
       (define p.D 41e-3) ; meters
       (define p.N_2 (array #[110 200 300]))
       (define m.ε_ind (array/ (array #[6 9 195])
                               (array #[1e3]))) ; volts

       (match-define (regression-estimate a b std-a std-b)
         (simple-linear-regression p.N_2 m.ε_ind))

       (cons
        `#hasheq([a . ,a] [b . ,b])
        (parameterize ([plot-width 610]
                       [plot-height 410]
                       [plot-x-label (scale math-scale (tex-math "N_2"))]
                       [plot-x-far-axis? #f]
                       [plot-y-far-axis? #f]
                       [plot-x-ticks (fraction-ticks 10.0 10 #:precision 0)]
                       [plot-y-ticks (fraction-ticks 0.01 10 #:precision 2)])
          (let ([graph-points (map list (array->list p.N_2) (array->list m.ε_ind))])
            (plot
             (list (tick-grid)
                   (axes)
                   (points graph-points #:sym 'asterisk #:size 7)
                   (function (λ (x) (+ (* x a) b))
                             #:color "red"))
             #:x-min 0
             #:y-min 0
             #:x-max 350
             #:y-max 0.2
             #:out-file (build-path output-directory "plot-3.jpg"))))))

     (let ()
       (define p.I 30) ; miliamps
       (define p.f 3) ; kHz
       (define p.N_2 300)
       (define p.D (array #[40 32 25]))
       (define m.ε_ind (array/ (array #[195 121 102])
                               (array #[1e3]))) ; volts

       (match-define (regression-estimate a b std-a std-b)
         (simple-linear-regression p.D m.ε_ind))

       (cons
        `#hasheq([a . ,a] [b . ,b])
        (parameterize ([plot-width 610]
                       [plot-height 410]
                       [plot-x-label (scale math-scale (tex-math "D (\\mathrm{mm})"))]
                       [plot-x-far-axis? #f]
                       [plot-y-far-axis? #f]
                       [plot-x-ticks (fraction-ticks 1.0 10 #:precision 0)]
                       [plot-y-ticks (fraction-ticks 0.01 10 #:precision 2)])
          (let ([graph-points (map list (array->list p.D) (array->list m.ε_ind))])
            (plot
             (list (tick-grid)
                   (axes)
                   (points graph-points #:sym 'asterisk #:size 7)
                   (function (λ (x) (+ (* x a) b))
                             #:color "red"))
             #:x-min 0
             #:y-min 0
             #:x-max 45
             #:y-max 0.2
             #:out-file (build-path output-directory "plot-4.jpg")))))))))

(write-json-to (build-path output-directory "data.json")
               (map car data-plot-pairs))

(map cdr data-plot-pairs)

; ervin seleni
