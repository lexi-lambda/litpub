#lang racket/base

(require json
         web-server/http)

(provide response/jsexpr)

(define APPLICATION/JSON-CONTENT-TYPE #"application/json; charset=utf-8")

(define (response/jsexpr jsexpr
                         #:code [code 200]
                         #:message [message #"OK"]
                         #:seconds [seconds (current-seconds)]
                         #:mime-type [mime-type APPLICATION/JSON-CONTENT-TYPE]
                         #:headers [headers '()])
  (response/full code message seconds mime-type headers
                 (list (jsexpr->bytes jsexpr))))
