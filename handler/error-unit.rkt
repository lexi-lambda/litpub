#lang racket/unit

(require web-server/http
         "../template.rkt"
         
         "../route-sig.rkt"
         "error-sig.rkt"
         "story-sig.rkt")

(import route^ (prefix stories: story^))
(export error^)

(define (not-found req)
  (response/xexpr #:code 404 #:message #"Not Found"
                  (page "Page Not Found"
                        `((div [[class "content"]]
                               (h1 "404 Not Found")
                               (p "There’s nothing here! Sorry about that. If you’re lost, "
                                  (a [[href ,(server-url stories:index)]]
                                     "here’s the way back to safety") "."))))))
