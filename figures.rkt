#lang racket/base

(require (only-in racket/function curry)
         racket/match
         racket/contract

         math

         metapict
         metapict/shapes
         pict/color
         latex-pict)

(provide vec-rotate
         vec-unit

         triangle
         quad
         square
         angle-diagram arrow-diagram

         (struct-out round-object)
         (struct-out rectangular-object)

         make-vector-arrow (struct-out vector-arrow)
         make-diagram-vector (struct-out diagram-vector)

         make-diagram-angle (struct-out diagram-angle)
         make-slope-config (struct-out slope-config)

         default-normal-vec
         slope-force-diagram pendulum-force-diagram)

(define pi/2 (/ pi 2))
(define 2pi (* pi 2))

(define (drawable? x) ((or/c pict? curve:? label? #f (listof drawable?)) x))

(define (vec-rotate v a)
  (let ([complex (* (make-rectangular (vec-x v) (vec-y v))
                    (make-polar 1 a))])
    (vec (real-part complex) (imag-part complex))))

(define/match (vec-unit v)
  [((vec x y)) (let ([len (norm v)])
                 (vec (/ x len) (/ y len)))])

(define triangle
  (match-λ*
   [(list (? pt? p1) (? pt? p2) (? pt? p3))
    (curve p1 -- p2 -- p3 -- cycle)]

   [(list (? pt? p) (? number? w) (? number? h))
    (triangle p (pt+ p (vec w 0)) (pt+ p (vec w h)))]

   [(list (? pt? p) (? vec? v))
    (triangle p (vec-x v) (vec-y v))]))

(define (quad p1 p2 p3 p4)
  (curve p1 -- p2 -- p3 -- p4 -- cycle))

(define (square p s)
  (match-let ([(pt px py) p])
    (quad p (pt px (+ py s)) (pt+ p (vec s s)) (pt (+ px s) py))))

(define (pict-radius pict)
  (norm (vec/ (vec (pict-width pict) (pict-height pict)) 2)))

(define/contract (angle-diagram p v theta name)
  (-> pt? vec? (real-in (- 2pi) 2pi) (or/c pict? string?) drawable?)
  (let ([mid-v (vec-rotate v (/ theta 2))]
        [p1 (pt+ p v)]
        [p2 (pt+ p (vec-rotate v theta))])
    (list
     (arc p p1 p2)
     (label-cnt name (pt+ p mid-v (vec* (px (pict-radius name))
                                        (vec@ 1 (angle mid-v))))))))

(define/contract (arrow-diagram o v [color (current-arrow-color)])
  (->* (pt? vec?) (color/c) pict?)
  (draw-arrow (curve o -- (pt+ o v)) #:color color))

(define (vec-lengthen v u)
  (let ([angle (atan (vec-y v) (vec-x v))])
    (vec+ v (vec (* (cos angle) u)
                 (* (sin angle) u)))))

(struct round-object (radius) #:transparent)
(struct rectangular-object (width height) #:transparent)
(define diagram-object? (or/c round-object? rectangular-object?))

(define (make-vector-arrow #:color color #:name name #:thickness [thickness 2])
  (vector-arrow color name thickness))
(struct vector-arrow
  (color name thickness)
  #:transparent)

(define (make-diagram-vector #:color color
                             #:name name
                             #:length length
                             #:decompose-x [dec-x #f]
                             #:decompose-y [dec-y #f]
                             #:thickness [thickness 2])
  (diagram-vector color name thickness length dec-x dec-y))
(struct diagram-vector vector-arrow
  (length decompose-x decompose-y)
  #:transparent)

(define (make-diagram-angle name
                            [show-at #f]
                            #:thickness [thickness 1]
                            #:color [color "black"])
  (diagram-angle name thickness color show-at))
(struct diagram-angle (name thickness color show-at) #:transparent)

(define (make-slope-config #:color color
                           #:line-color line-color
                           #:line-thickness [line-thickness 1])
  (slope-config color line-color line-thickness))
(struct slope-config
  (color line-color line-thickness)
  #:transparent)

(define/match (prepare-diagram-object object pos)
  [((round-object radius) _) (circle pos radius)]
  [((rectangular-object width height) _) (let ([diag (vec width height)])
                                           (rectangle (pt- pos (vec* 1/2 diag))
                                                      diag))])

(define/match (diagram-object-height-from-center object)
  [((round-object radius)) radius]
  [((rectangular-object _ height)) (/ height 2)])

(define (diagram-angle-shows-at? show-at-registry thing)
  (cond
    [(or (eq? show-at-registry #f) (eq? show-at-registry 'all)) #t]
    [(member thing show-at-registry) #t]
    [else #f]))

(define default-normal-vec
  (make-parameter (make-vector-arrow
                   #:color #f
                   #:name (tex-math "\\overrightarrow{F}_N"))))
(define default-theta
  (make-parameter (make-diagram-angle
                   (tex-math "\\theta")
                   'all)))

(define/contract (slope-force-diagram
                  pos width height object object-offset
                  #:object-color obj-color
                  #:slope slope
                  #:gravity-vec g-vec
                  #:object-center-circle [oc-radius 0]
                  #:force-vec [f-vec #f]
                  #:force-angle [f-angle #f]
                  #:friction-vec [ff-vec #f]
                  #:friction-length-ratio [ff-length-ratio 1]
                  #:friction-direction [ff-dir 'up]
                  #:theta [angle-info (default-theta)]
                  #:normal-vec [fn-vec (default-normal-vec)])
  (->* (pt?
        real?
        (and/c real? positive?)
        diagram-object?
        (real-in 0 1)
        #:object-color color/c
        #:slope slope-config?
        #:gravity-vec diagram-vector?)
       (#:object-center-circle (and/c real? positive?)
        #:force-vec (or/c #f diagram-vector?)
        #:force-angle (real-in (- 2pi) 2pi)
        #:friction-vec vector-arrow?
        #:friction-direction (one-of/c 'up 'down)
        #:theta diagram-angle?
        #:normal-vec vector-arrow?)
       drawable?)

  (define object-height
    (match-λ
     [(round-object radius) radius]
     [(rectangular-object width height) height]))

  (match-define (diagram-vector g-color
                                g-name
                                g-thickness
                                g-length
                                gx-vec
                                gy-vec)
    g-vec)
  (match-define (vector-arrow gx-color gx-name gx-thickness)
    (or gx-vec
        (vector-arrow #f #f #f)))
  (match-define (vector-arrow gy-color gy-name gy-thickness)
    (or gy-vec
        (vector-arrow #f #f #f)))
  
  (match-define (vector-arrow param-fn-color fn-name fn-thickness) fn-vec)

  (define contact-point (pt+ pos (vec* object-offset (vec width height))))
  (define object-center
    (pt+ contact-point
         (vec-lengthen
          (vec* (object-height object)
                (vec-rotate (vec-unit (pt- pos contact-point))
                            (if (> width 0) (- pi/2) pi/2)))
          (px (/ (slope-config-line-thickness slope) 2)))))
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;; TODO: Handle the cases when width < 0 ;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (define slope-angle (atan height width))
  (define g (vec 0 (- g-length)))
  (define gx (vec@ (* (sin slope-angle) g-length)
                   (+ pi slope-angle)))
  (define gy (vec@ (* (cos slope-angle) g-length)
                   (- slope-angle pi/2)))
  (define fn-color (or param-fn-color g-color))


  (list
   (color (slope-config-color slope) (fill (triangle pos width height)))

   (penwidth (slope-config-line-thickness slope)
             (color (slope-config-line-color slope)
                    (draw (curve pos -- (pt+ pos (vec width height))))))

   (color obj-color
          (fill (prepare-diagram-object object object-center)))

   (when (diagram-angle-shows-at? (diagram-angle-show-at angle-info) 'slope)
     (let ([gx-arrow-x (+ (pt-x object-center) (vec-x gx))])

       ; TODO: Refactor this into a function
       (penwidth (diagram-angle-thickness angle-info)
                 (color
                  (diagram-angle-color angle-info)
                  (draw
                   (angle-diagram
                    pos
                    (vec (/ (- gx-arrow-x (pt-x pos)) 2) 0)
                    slope-angle
                    (diagram-angle-name angle-info)))))))

   (when (diagram-angle-shows-at? (diagram-angle-show-at angle-info) 'g-gy)
     (penwidth (diagram-angle-thickness angle-info)
               (color
                (diagram-angle-color angle-info)
                (draw
                 (angle-diagram
                  object-center
                  ; NOTE: probably another case where width < 0 needs
                  ;       to be considered
                  (vec 0 (/ (- (pt-y pos) (pt-y object-center)) 2))
                  slope-angle
                  (diagram-angle-name angle-info))))))

   (match ff-vec
     [#f #f]
     [(vector-arrow ff-color ff-name ff-thickness)
      (define ff-angle (match ff-dir
                         ['up slope-angle]
                         ['down (+ slope-angle pi)]))
      (define arrow-pos (pt+ contact-point
                             (vec@ (* (norm gx) ff-length-ratio)
                                   ff-angle)))
      (list
       (label-ulft ff-name arrow-pos)
       (penwidth ff-thickness
                 (draw-arrow
                  ; TODO: Make it use some contact point further out
                  ;       in the case of rectangular etc objects
                  (curve contact-point --
                         arrow-pos)
                  #:color ff-color)))])
   ; TODO: Refactor all the `(if thing #f)`s into a macro
   ; NOTE: Maybe refactor this as well
   (when gx
     (penwidth
      gx-thickness
      (draw
       (label-lft gx-name (pt+ object-center gx))
       (arrow-diagram object-center gx gx-color)
       (color (change-alpha gx-color 0.5)
              (dashed
               (draw (curve (pt+ object-center gx) --
                            (pt+ object-center g))))))))

   (when gy
     (penwidth
      gy-thickness
      (draw
       (label-lrt gy-name (pt+ object-center gy))
       (arrow-diagram object-center gy gy-color)
       (color (change-alpha gy-color 0.5)
              (dashed
               (draw (curve (pt+ object-center gy) --
                            (pt+ object-center g))))))))
   
   (let ([fn-arrow-pos (pt+ contact-point (vec-rotate gy (- pi)))])
     (list
      (penwidth
       fn-thickness
       (color fn-color
              ; TODO: May need to account for `width < 0`
              (draw-arrow (curve contact-point -- fn-arrow-pos))))

      (label-ulft fn-name fn-arrow-pos)))

   (label-lft g-name (pt+ object-center g))
   (penwidth g-thickness (arrow-diagram object-center g g-color))

   ; TODO: Parameterize this color
   (color "black" (fill (circle object-center oc-radius)))))

(define positive-real? (and/c real? positive?))

(define default-phi
  (make-parameter (make-diagram-angle
                   (tex-math "\\varphi")
                   'all)))

(define/contract (pendulum-force-diagram
                  object pos line-length start-angle
                  #:gravity-vec g-vec
                  #:tension-vec t-vec
                  #:line-thickness [line-thickness 2]
                  #:line-length-name [line-name (tex-math "\\lambda")]
                  #:equilibrium-line-color [equib-line-color "black"]
                  #:start-line-color [start-line-color "black"]
                  #:equilibrium-position-name [eq-pos-name #f]
                  #:start-position-name [start-pos-name #f]
                  #:position-distance-name [pos-dist-name #f]
                  #:object-outline-thickness [obj-out-thickness 2]
                  #:object-outline-color [obj-out-color "black"]
                  #:object-color [obj-color "white"]
                  #:arc-color [arc-color "black"]
                  #:arc-thickness [arc-thickness 1]
                  #:arc-extra-angle [arc-angle (/ pi 20)]
                  #:phi [angle-info (default-phi)])
  (->* (diagram-object?
        pt?
        positive-real?
        ; TODO: Handle negative angles
        (real-in (- pi/2) pi/2)
        #:gravity-vec diagram-vector?
        #:tension-vec vector-arrow?)
       (#:line-thickness positive-real?
        #:line-length-name (or/c #f string? pict?)
        #:equilibrium-line-color color/c
        #:start-line-color color/c
        ; TODO: Implement the position names ;;;;;;;;;;;;;;;;
        #:equilibrium-position-name (or/c #f string? pict?)
        #:start-position-name (or/c #f string? pict?)
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        #:position-distance-name (or/c #f string? pict?)
        #:object-outline-thickness positive-real?
        #:object-outline-color color/c
        #:object-color color/c
        #:arc-color color/c
        #:arc-thickness positive-real?
        #:arc-extra-angle (real-in (- 2pi) 2pi)
        #:phi diagram-angle?)
       any)

  (define pos-equib-vec (vec 0 (- line-length)))
  (define obj-equib-pos (pt+ pos pos-equib-vec))
  (define obj-start-pos (pt+ pos (vec-rotate pos-equib-vec start-angle)))
  (define equib-obj (prepare-diagram-object object obj-equib-pos))
  (define start-obj
    (rotated-about start-angle
                   obj-start-pos
                   (prepare-diagram-object object obj-start-pos)))
  (define t-orig
    (pt+ obj-start-pos
         (vec-rotate (vec 0 (diagram-object-height-from-center object))
                     start-angle)))
  
  (match-define (vector-arrow t-color t-name t-thickness) t-vec)
  (match-define (diagram-vector g-color
                                g-name
                                g-thickness
                                g-length
                                g-decompose-x
                                g-decompose-y) g-vec)
  (define g (vec 0 (- g-length)))
  (define gx (vec@ (* (sin start-angle) g-length)
                   (+ pi start-angle)))
  (define gy (vec@ (* (cos start-angle) g-length)
                   (- start-angle pi/2)))
  (define t (vec@ (norm gy) (+ pi/2 start-angle)))

  (match-define
    (diagram-angle angle-name angle-thickness angle-color angle-show-at)
    angle-info)

  (list
   (color arc-color
          (penwidth
           arc-thickness
           (draw (arc pos
                      (pt+ pos (vec-rotate pos-equib-vec (- arc-angle)))
                      (pt+ pos
                           (vec-rotate pos-equib-vec
                                       (+ start-angle arc-angle)))))))

   (when pos-dist-name
     (list
      (label-top pos-dist-name (pt+ obj-start-pos
                                    (vec/ (pt- obj-equib-pos
                                               obj-start-pos)
                                          2)))
      (color arc-color
             (penwidth
              arc-thickness (draw (curve obj-start-pos -- obj-equib-pos))))))

   (when (diagram-angle-shows-at? angle-show-at 'g-gy)
     (penwidth angle-thickness
               (color
                angle-color
                (draw
                 (angle-diagram
                  pos
                  (vec 0 (/ line-length -4))
                  start-angle
                  angle-name)))))

   (color start-line-color
          (penwidth line-thickness
                    (draw (curve pos -- obj-start-pos))))
   (color equib-line-color
          (penwidth line-thickness
                    (draw (curve pos -- obj-equib-pos))))
   (label-lft line-name (pt+ pos (vec/ pos-equib-vec 2)))

   (penwidth t-thickness
             (color t-color (draw-arrow (curve t-orig -- (pt+ t-orig t)))))
   (label-urt t-name (pt+ t-orig t))

   ; TODO: Maybe put these into for loop macros
   (brushcolor obj-color (draw (fill equib-obj)))
   (penwidth obj-out-thickness
             (pencolor obj-out-color (draw equib-obj)))
   (brushcolor obj-color (draw (fill start-obj)))
   (penwidth obj-out-thickness
             (pencolor obj-out-color (draw start-obj)))
   
   ; TODO: Refactore these into function
   (match g-decompose-x
     [(vector-arrow gx-color gx-name gx-thickness)
      (list (color (change-alpha gx-color 0.5)
                   (dashed (draw (curve (pt+ obj-start-pos gx) --
                                        (pt+ obj-start-pos g)))))
            (penwidth gx-thickness
                      (color gx-color
                             (draw-arrow (curve obj-start-pos --
                                                (pt+ obj-start-pos gx)))))
            (label-cnt gx-name
                       (pt+ obj-start-pos
                            gx
                            (vec@ (px (pict-radius gx-name))
                                  (+ (angle gx) (/ pi 4))))))]
     [#f '()])

   (match g-decompose-y
     [(vector-arrow gy-color gy-name gy-thickness)
      (list (color (change-alpha gy-color 0.5)
                   (dashed (draw (curve (pt+ obj-start-pos gy) --
                                        (pt+ obj-start-pos g)))))
            (penwidth gy-thickness
                      (color gy-color
                             (draw-arrow (curve obj-start-pos --
                                                (pt+ obj-start-pos gy)))))
            (label-rt gy-name (pt+ obj-start-pos gy)))]
     [#f '()])

   (penwidth g-thickness
             (color g-color
                    (draw-arrow (curve obj-start-pos --
                                       (pt+ obj-start-pos g)))))
   (label-bot g-name (pt+ obj-start-pos g))))

(module+ test)
(module+ main)

; (require racket/port
;          racket/string
;          racket/contract)
; 
; (define/contract (force-intger i)
;   (-> integer? integer?)
;   i)
; 
; (map (compose force-integer string->number string-trim)
;      (call-with-input-file port->string))
; 
