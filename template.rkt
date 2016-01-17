#lang racket/base

(require (only-in "environment.rkt" google-analytics-tracking-id))

(provide page)

(define (asset-url path)
  (string-append "/assets/" path))

(define google-analytics-js #<<JS
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', '~a', 'auto');
  ga('send', 'pageview');
JS
  )

(define (page title body)
  `(html (head (meta [[charset "utf8"]])
               (title ,title)
               (link [[rel "stylesheet"]
                      [href ,(asset-url "styles/main.css")]]))
         (body [[class "no-transitions"]]
               ,@body
               ,@(if google-analytics-tracking-id
                     `((script ,(format google-analytics-js google-analytics-tracking-id)))
                     '())
               (script "document.body.className = '';"))))
