#lang racket/base

(require data/collection
         db/base
         threading
         (prefix-in db: "db.rkt"))

(provide (struct-out story) query-stories query-story story-slug)

(struct story [id title body created-at updated-at draft?])

(define (vector->story vec)
  (apply story (vector->immutable-vector vec)))

(define (query-stories)
  (map vector->story (query-rows db:connection "SELECT * FROM stories")))

(define (query-story id)
  (and~>> (query-maybe-row db:connection "SELECT * FROM stories WHERE id = $1" id)
          vector->story))

(define (story-slug story)
  (regexp-replace* #rx"[^a-z]+" (string-downcase (story-title story)) "-"))
