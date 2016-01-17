#lang racket/unit

(require data/collection
         racket/function
         web-server/http
         "../model.rkt"
         "../template.rkt"
         "../util/xexpr.rkt"

         "../route-sig.rkt"
         "error-sig.rkt"
         "story-sig.rkt")

(import route^ (prefix errors: error^))
(export story^)

(define (index req)
  (define (list-stories stories)
    `(ul . ,(for/list ([story (in stories)])
              `(li (a [[href ,(server-url show (story-id story) (story-slug story))]]
                      ,(story-title story))))))
  (let ([all-stories (query-stories)])
    (response/xexpr
     (page "Stories"
           `((div [[class "content"]]
                  (h1 "Stories")
                  ,(list-stories (filter (negate story-draft?) all-stories))
                  (h2 "Drafts & Works in Progress")
                  ,(list-stories (filter story-draft? all-stories))))))))

(define (show req id slug)
  (define story (query-story id))
  (cond
    [(not story) (errors:not-found req)]
    [(equal? slug (story-slug story))
     (response/xexpr
      (page (story-title story)
            `((div [[class "content"]]
                   (h1 ,(story-title story))
                   ,@(process-markdown (story-body story))))))]
    [else (redirect-to (server-url show id (story-slug story)))]))
