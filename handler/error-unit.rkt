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

(define (internal-server-error url exn)
  ((error-display-handler) (exn-message exn) exn)
  (response/xexpr #:code 500 #:message #"Internal Server Error"
                  (page "Internal Server Error"
                        `((div [[class "content"]]
                               (h1 "Internal Server Error")
                               (p "Something blew up. Try reloading the page. If the problem "
                                  "persists, contact "
                                  (a [[href "mailto:lexi.lambda@gmail.com"]]
                                     "lexi.lambda@gmail.com")
                                  " and let me know what’s going on.")
                               (p "Or, y’know, just try to go "
                                  (a [[href ,(server-url stories:index)]]
                                     "somewhere else") "."))))))
