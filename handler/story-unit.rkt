#lang racket/unit

(require data/collection
         db/util/datetime
         racket/format
         racket/function
         srfi/19
         web-server/http
         "../model.rkt"
         "../template.rkt"
         "../util/client-ip.rkt"
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
  (define ip (client-ip req))
  (cond
    [(not story) (errors:not-found req)]
    [(equal? slug (story-slug story))
     (response/xexpr
      (page (story-title story)
            `((div [[class "content"]]
                   (a [[class "pull-gutter"] [href ,(server-url index)]] "← Index")
                   (h1 ,(story-title story))
                   ,@(process-markdown (story-body story))
                   (hr)
                   (div [[class "after-content"]]
                        (div [[style "float: right"]]
                             (span [[class "dateline subdued"] [style "line-height: 2em"]]
                                   ,(date->string (sql-datetime->srfi-date (story-created-at story))
                                                  "~B ~e, ~Y")))
                        (a [[href "#"]
                            [class ,(string-append
                                     "toggle-button toggle-button--icon story-like-button"
                                     (if (story-liked? id ip) " toggle-button--selected" ""))]
                            [data-story-id ,(~a id)]]
                           (i [[class "octicon-heart"]]))
                        (span [[class "counter story-like-counter subdued"]]
                              ,(~a (story-count-likes id))))))))]
    [else (redirect-to (server-url show id (story-slug story)))]))
