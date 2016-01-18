#lang racket/unit

(require "../model.rkt"
         "../util/client-ip.rkt"
         "../util/jsexpr.rkt"
         
         "api-sig.rkt")

(import)
(export api^)

(define (story-likes:create req story-id)
  (let ([ip (client-ip req)])
    (create-story-like! story-id ip)
    (response/jsexpr #:code 201 #:message #"Created"
                     `#hasheq((status . "ok")
                              (score . ,(story-count-likes story-id))))))

(define (story-likes:destroy req story-id)
  (let ([ip (client-ip req)])
    (destroy-story-like! story-id ip)
    (response/jsexpr `#hasheq((status . "ok")
                              (score . ,(story-count-likes story-id))))))
