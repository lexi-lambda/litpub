#lang racket/base

(require data/collection
         db/base
         threading
         (prefix-in db: "db.rkt"))

(provide (struct-out story) query-stories query-story story-slug story-sum-votes
         (struct-out story-vote) create-story-vote!)

(struct story [id title body draft? created-at updated-at] #:transparent)
(struct story-vote [id story-id ip value created-at updated-at] #:transparent)

;; stories
(define (vector->story vec)
  (apply story (vector->immutable-vector vec)))

(define (query-stories)
  (map vector->story (query-rows db:connection "SELECT * FROM stories ORDER BY updated_at ASC")))

(define (query-story id)
  (and~>> (query-maybe-row db:connection "SELECT * FROM stories WHERE id = $1" id)
          vector->story))

(define (story-slug story)
  (regexp-replace* #rx"[^a-z]+" (string-downcase (story-title story)) "-"))

(define (story-sum-votes story-id)
  (query-value db:connection #<<SQL
SELECT SUM(CASE WHEN value = 'up' THEN 1 ELSE -1 END)
FROM story_votes
WHERE story_id = $1
SQL
               story-id))

;; story_votes
(define (create-story-vote! story-id ip value)
  (query-exec db:connection #<<SQL
INSERT INTO story_votes (story_id, ip, value)
VALUES ($1, $2::text::inet, $3::text::binary_vote)
ON CONFLICT (story_id, ip)
DO UPDATE SET value = EXCLUDED.value, updated_at = now()
SQL
              story-id ip value))
