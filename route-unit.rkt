#lang racket/unit

(require web-server/dispatch

         "route-sig.rkt"
         "handler/api-sig.rkt"
         "handler/feedback-sig.rkt"
         "handler/story-sig.rkt")

(import (prefix api: api^)
        (prefix feedback: feedback^)
        (prefix stories: story^))
(export route^)

(define-values [server-dispatch server-url]
  (dispatch-rules
   [("") #:method "get" stories:index]
   [("stories" (integer-arg) (string-arg)) #:method "get" stories:show]
   
   [("feedback") #:method "get" feedback:form]
   [("feedback") #:method "post" feedback:submit]

   [("api" "stories" (integer-arg) "likes") #:method "post" api:story-likes:create]
   [("api" "stories" (integer-arg) "likes") #:method "delete" api:story-likes:destroy]))
