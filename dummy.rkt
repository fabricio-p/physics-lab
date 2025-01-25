#lang racket/base

(require racket/rerequire
         racket/class
         (only-in racket/function curry)
         racket/format
         (only-in racket/draw brush%)
         (only-in math pi)

         metapict
         metapict/crop
         latex-pict
         racket-poppler/render-tex)

(latex-path "/home/fabricio/installed/latex/texlive/2024/bin/x86_64-linux/pdflatex")

(dynamic-rerequire "figures.rkt") (require "figures.rkt")


(define ($ str [scale-factor 1.5] #:preamble [preamble (current-preamble)])
  (scale scale-factor (tex-math str #:preamble preamble)))

(define (overrightarrow str) (~a "\\overrightarrow{\\rule[10pt]{0pt}{0pt}{" str "}}"))



