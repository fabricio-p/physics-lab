#lang racket/base

(require math/array

         "util.rkt")

(define c.g 9.81)
(define p.m 16e-3)
(define p.M 40e-3)
(define p.l 25e-2)

(define m.alphas (array #[#[18 28 40]
                          #[20 30 45]
                          #[21 32 44]]))

(define (pre-velocities g l m M alphas)
  (let ([c (* 2 (/ (+ m M) m) (sqrt (* g l)))])
    (array* (array #[c])
            (array-map sin (array/ alphas
                                   (array #[2]))))))

(define (post-velocities g l alphas)
  (let ([c (* 2 (sqrt (* g l)))])
    (array* (array #[c])
            (array-map sin (array/ alphas (array #[2]))))))

(define (pre-kinetic-energies m vs)
  (array* (array #[(/ m 2)]) (array-sqr vs)))

(define (post-kinetic-energies m M us)
  (array* (array #[(/ (+ m M) 2)]) (array-sqr us)))

(module+ main
  (require racket/file racket/math (only-in racket/file make-directory*))

  (define output-directory
    (resolve-path (string->path "./exercise-results/exercise-7")))
  (define avg-alphas (rows-mean m.alphas))
  (define avg-rad-alphas (array-map degrees->radians avg-alphas))
  (define vs (pre-velocities c.g p.l p.m p.M avg-rad-alphas))
  (define us (post-velocities c.g p.l avg-rad-alphas))
  (define E_k1s (pre-kinetic-energies p.m vs))
  (define E_k2s (post-kinetic-energies p.m p.M us))
  (define E_k2/E_k1s (array/ E_k2s E_k1s))
  (define mass-ratio (/ p.m (+ p.m p.M)))

  (make-directory* output-directory)
  (parameterize ([base-directory output-directory])
    (write-json-to
     "data.json"
     `#hasheq([avg-alphas . ,(array->list avg-alphas)]
              [vs . ,(array->list vs)]
              [us . ,(array->list us)]
              [E_k1s . ,(array->list E_k1s)]
              [E_k2s . ,(array->list E_k2s)]
              [E_k-ratio . ,(array->list E_k2/E_k1s)]
              [mass-ratio . ,mass-ratio]))))
