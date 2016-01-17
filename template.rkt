#lang racket/base

(provide page)

(define (asset-url path)
  (string-append "/assets/" path))

(define (page title body)
  `(html (head (meta [[charset "utf8"]])
               (title ,title)
               (link [[rel "stylesheet"]
                      [href ,(asset-url "styles/main.css")]]))
         (body [[class "no-transitions"]]
               ,@body
               (script "document.body.className = '';"))))
