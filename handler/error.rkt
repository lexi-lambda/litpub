#lang racket/base

(require web-server/http
         "../template.rkt")

(provide not-found)

(define (not-found req)
  (response/xexpr #:code 404 #:message #"Not Found"
                  (page "Page Not Found"
                        '((div [[class "content"]]
                               (h1 "404 Not Found")
                               (p "There’s nothing here! Sorry about that. If you’re lost, "
                                  (a [[href "/"]] "here’s the way back to safety") "."))))))
