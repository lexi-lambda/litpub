#lang racket/base

(require web-server/dispatch
         (prefix-in stories: "handler/story.rkt"))

(provide server-dispatch server-url)

(define-values [server-dispatch server-url]
  (dispatch-rules
   [("") stories:index]
   [("stories" (integer-arg) (string-arg)) stories:show]))
