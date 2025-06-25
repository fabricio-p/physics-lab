#lang debug racket/base

(require racket/match
         racket/format
         racket/list
         racket/file
         racket/class
         (only-in racket/function curry curryr)
         ; (only-in racket/file make-directory*)
         (only-in math pi sqr degrees->radians)
         math/array

         "util.rkt"
         "main.rkt")

(define output-directory
  (resolve-path (string->path "./exercise-results/exercise-15")))
(make-directory* output-directory)

(define p.I (array #[0.2 0.3 0.4 0.5 0.6]))
(define p.N 1)
; (define R 2.5e-2)
(define c.μ₀ (* pi 4e-7))
(define p.R 6e-2)

(define (Bₗ I)
  (array/ (array* (array #[c.μ₀]) I (array #[p.N]))
          (array #[(* 2 p.R)])))

(define (B_H Bₗ α)
  (array/ Bₗ (array-map (compose tan degrees->radians) α)))

(define m.α₁ (array #[30 45 50 57 60]))
(define m.α₂ (array #[30 41 50 55 60]))

(define (prepare-row αs Is)
  (let* ([Bₗs (Bₗ Is)]
         [B_Hs (B_H Bₗs αs)])
    (for/list ([α (array->list αs)]
               [I (array->list Is)]
               [Bₗ (array->list Bₗs)]
               [B_H (array->list B_Hs)])
      `#hasheq([value . ,α]
               [tan . ,(tan (degrees->radians α))]
               [Idivtan . ,(/ I (tan (degrees->radians α)))]
               [I . ,I]
               [B_l . ,Bₗ]
               [B_H . ,B_H]))))

(let* ([Bₗ (Bₗ p.I)]
       [B_H (array-mean (array-list->array (list (B_H Bₗ m.α₁)
                                                 (B_H Bₗ m.α₂))) 0)]
       [indices (array #[1 2 3 4 5])]
       [data (array-axis-swap
              (array-list->array (list indices p.I m.α₁ m.α₂ Bₗ B_H))
              0
              1)])
  
  #;(write-json-to (build-path output-directory "data.json")
                   (array->list* #R data))

  (write-json-to (build-path output-directory "data.json")
                 `#hasheq([alpha-1 . ,(prepare-row m.α₁ p.I)]
                          [alpha-2 . ,(prepare-row m.α₂ p.I)]
                          [mudiv2R . ,(/ c.μ₀ 2 p.R)])))

