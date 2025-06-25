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

         "util.rkt"
         "main.rkt")

(define p.m (array #[50 100 150 200]))
(define p.ρ 1.56e-3) ; kg / m
(define p.n (array #[#[1 2 3 4]
                     #[1 2 3 4]
                     #[1 2 3 0]
                     #[1 2 3 0]]))
(define m.lₙ (array #[#[#[18.0 36.2 58.8  78.4]
                        #[13.0 35.3 59.0  78.0]
                        #[18.8 35.0 58.6  78.6]]
                      #[#[23.6 45.3 68.0 103.4]
                        #[23.4 45.6 68.2 103.2]
                        #[23.8 45.0 68.1 103.3]]
                      #[#[27.8 56.2 87.0   0.0]
                        #[28.6 56.0 87.1   0.0]
                        #[29.2 56.3 87.2   0.0]]
                      #[#[29.5 60.8 93.7   0.0]
                        #[29.7 60.5 93.8   0.0]
                        #[29.3 70.0 93.9   0.0]]]))

(define P (array/ p.m (array 100.0)))
(define lₙ (array-mean m.lₙ 1))
(define f (array* #R(array/ p.n (array 2) lₙ (array 1/100))
                  #R(array-sqrt (array/ P (array p.ρ)))))

; (list p.m P lₙ f)
; (map list (array->list p.m) (array->list P) (array->list* lₙ))


(define output-directory
  (resolve-path (string->path "./exercise-results/exercise-12")))
(make-directory* output-directory)

(write-json-to (build-path output-directory "data.json")
               `#hasheq([l_n-table . ,(map list
                                           (array->list p.m)
                                           (array->list P)
                                           (array->list* lₙ))]
                        [f-table . ,(map list
                                         (array->list p.m)
                                         (array->list P)
                                         (array->list* f))]
                        [table . ,(map list
                                       (array->list p.m)
                                       (array->list P)
                                       (array->list (array-sqrt (array/ P (array p.ρ))))
                                       (array->list* lₙ)
                                       (array->list* (array/ p.n (array 2) lₙ (array 1/100)))
                                       (array->list* f))]
                        [rho . ,(* p.ρ 1e3)]))


