#lang curly-fn racket/base

(require hyphenate
         (only-in markdown parse-markdown)
         racket/list
         txexpr)

(provide hang-open-quotes process-xexpr process-markdown)

(define (hang-open-quotes xexpr)
  (if (equal? 'p (get-tag xexpr))
      (let loop ([xexpr xexpr])
        (let* ([elems (get-elements xexpr)])
          (if (empty? elems)
              xexpr
              (let ([first-elem (first elems)])
                (txexpr (get-tag xexpr)
                        (get-attrs xexpr)
                        (cond [(equal? 'ldquo first-elem)
                               (cons '(span [[class "hanging-double-quote"]] ldquo) (rest elems))]
                              [(list? first-elem) (cons (loop first-elem) (rest elems))]
                              [else (get-elements xexpr)]))))))
      xexpr))

(define process-xexpr
  (compose1 hang-open-quotes hyphenate))

(define process-markdown
  (compose1 #{map process-xexpr} parse-markdown))
