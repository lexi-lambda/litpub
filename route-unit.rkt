#lang racket/unit

(require web-server/dispatch

         "route-sig.rkt"
         "handler/api-sig.rkt"
         "handler/story-sig.rkt")

(import (prefix api: api^)
        (prefix stories: story^))
(export route^)

(define-values [server-dispatch server-url]
  (dispatch-rules
   [("") stories:index]
   [("stories" (integer-arg) (string-arg)) stories:show]

   [("api" "story-votes") #:method "post" api:story-votes:create]))
