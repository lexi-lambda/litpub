#lang racket/unit

(require json
         web-server/http
         "../model.rkt"
         "../util/client-ip.rkt"
         "../util/jsexpr.rkt"
         
         "api-sig.rkt")

(import)
(export api^)

(define (story-votes:create req)
  (let* ([payload (bytes->jsexpr (request-post-data/raw req))]
         [ip (client-ip req)]
         [story-id (hash-ref payload 'story-id)]
         [value (hash-ref payload 'value)])
    (create-or-update-story-vote! story-id ip value)
    (response/jsexpr #:code 201 #:message #"Created"
                     `#hasheq((status . "ok")
                              (score . ,(story-sum-votes story-id))))))
