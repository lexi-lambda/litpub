#lang racket/base

(require data/collection
         db/base
         threading
         (prefix-in db: "db.rkt"))

(provide (struct-out story) query-stories query-story story-slug story-liked? story-count-likes
         create-story-like! destroy-story-like! create-user-feedback!)

(struct story [id title body draft? created-at updated-at] #:transparent)

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

(define (story-liked? story-id ip)
  (not (zero? (query-value db:connection #<<SQL
SELECT COUNT(*)
FROM story_likes
WHERE story_id = $1 AND ip = $2::text::inet
SQL
                           story-id ip))))

(define (story-count-likes story-id)
  (query-value db:connection "SELECT COUNT(*) FROM story_likes WHERE story_id = $1" story-id))

;; story_likes
(define (create-story-like! story-id ip)
  (query-exec db:connection #<<SQL
INSERT INTO story_likes (story_id, ip)
VALUES ($1, $2::text::inet)
ON CONFLICT (story_id, ip) DO NOTHING
SQL
              story-id ip))

(define (destroy-story-like! story-id ip)
  (query-exec db:connection
              "DELETE FROM story_likes WHERE story_id = $1 AND ip = $2::text::inet"
              story-id ip))

;; user_feedback
(define (create-user-feedback! ip body)
  (query-exec db:connection
              "INSERT INTO user_feedback (ip, body) VALUES ($1::text::inet, $2)"
              ip body))
