#lang curly-fn racket/base

(require hyphenate
         (only-in markdown parse-markdown)
         racket/dict
         racket/list
         racket/string
         txexpr)

(provide hang-open-quotes process-xexpr process-markdown)

(define entity-mappings
  '((#\“ . ldquo)
    (#\” . rdquo)))

(define (normalize-character-as-entity char entity str)
  ; strip out pointless empty strings after splitting and joining
  (filter-not #{equal? ""} (add-between (string-split str (string char) #:trim? #f) entity)))

(define (normalize-characters-as-entities str)
  (for/fold ([xexprs (list str)])
            ([(char entity) (in-dict entity-mappings)])
    (append-map (λ (elem) (if (string? elem)
                              (normalize-character-as-entity char entity elem)
                              (list elem)))
                xexprs)))

; Before hanging open quotes, we want to get all the quotes in a canonical representation. It’s
; convenient to make them separate elements since we have to pull them out, anyway, so the entity
; representation is a good normalized form.
(define (normalize-xexpr-to-entities xexpr)
  (if (txexpr? xexpr)
      (txexpr (get-tag xexpr)
              (get-attrs xexpr)
              (append-map (λ (child) (if (string? child)
                                         (normalize-characters-as-entities child)
                                         (list (normalize-xexpr-to-entities child))))
                          (get-elements xexpr)))
      xexpr))

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
  (compose1 hang-open-quotes normalize-xexpr-to-entities hyphenate))

(define process-markdown
  (compose1 #{map process-xexpr} parse-markdown))

(module+ test
  (require rackunit
           rackunit/spec)

  (describe "normalize-xexpr-to-entities"
    (context "given a string"
      (it "returns the element"
        (check-equal? (normalize-xexpr-to-entities "Hello, world!") "Hello, world!")))
    
    (context "given a tagged element"
      (it "converts double quotes to entities"
        (check-equal? (normalize-xexpr-to-entities
                       '(div (h1 "Hello, world!")
                             (div "“This is a " (span "test,” she") " said.")))
                      '(div (h1 "Hello, world!")
                             (div ldquo "This is a " (span "test," rdquo " she") " said.")))))))
